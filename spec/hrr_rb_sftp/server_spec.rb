RSpec.describe HrrRbSftp::Server do
  let(:io){
    io_in  = IO.pipe
    io_out = IO.pipe
    io_err = IO.pipe
    Struct.new(:local, :remote).new(
      Struct.new(:in, :out, :err).new(io_in[0], io_out[1], io_err[1]),
      Struct.new(:in, :out, :err).new(io_in[1], io_out[0], io_err[0])
    )
  }

  let(:logger){
    if ENV["LOGGING"]
      require "logger"
      logger = Logger.new $stdout
      logger.level = ENV["LOGGING"]
      logger
    end
  }

  after :example do
    io.remote.in.close  rescue nil
    io.local.in.close   rescue nil
    io.local.out.close  rescue nil
    io.remote.out.close rescue nil
    io.local.err.close  rescue nil
    io.remote.err.close rescue nil
  end

  describe "#negotiate_version" do
    context "when receiving valid SSH_FXP_INIT" do
      let(:init_packet){
        {
          :"type"    => HrrRbSftp::Protocol::Common::Packets::SSH_FXP_INIT::TYPE,
          :"version" => version,
        }
      }
      let(:init_payload){
        HrrRbSftp::Protocol::Common::Packets::SSH_FXP_INIT.new.encode(init_packet)
      }

      before :example do
        @thread = Thread.new{
          server = described_class.new logger: logger
          server.start *io.local.to_a
        }
      end

      after :example do
        @thread.kill
      end

      [1, 2, 3].each do |version|
        context "when remote protocol version is #{version}" do
          let(:version){ version }

          it "receives init with version #{version} and returns version with version #{version}" do
            io.remote.in.write ([init_payload.bytesize].pack("N") + init_payload)
            payload_length = io.remote.out.read(4).unpack("N")[0]
            payload = io.remote.out.read(payload_length)
            expect( payload[0].unpack("C")[0] ).to eq HrrRbSftp::Protocol::Common::Packets::SSH_FXP_VERSION::TYPE
            packet = HrrRbSftp::Protocol::Common::Packets::SSH_FXP_VERSION.new.decode(payload)
            expect( packet[:"version"] ).to eq version
            if version < 3
              expect( packet[:"extensions"] ).to eq []
            else
              expect( packet[:"extensions"] ).to include({:"extension-name"=>"statvfs@openssh.com",  :"extension-data"=>"2"})
            end
          end
        end
      end
    end
  end

  describe "request and response loop" do
    let(:init_packet){
      {
        :"type"    => HrrRbSftp::Protocol::Common::Packets::SSH_FXP_INIT::TYPE,
        :"version" => version,
      }
    }
    let(:init_payload){
      HrrRbSftp::Protocol::Common::Packets::SSH_FXP_INIT.new.encode(init_packet)
    }

    before :example do
      @thread = Thread.new{
        server = described_class.new logger: logger
        server.start *io.local.to_a
      }
      io.remote.in.write ([init_payload.bytesize].pack("N") + init_payload)
      payload_length = io.remote.out.read(4).unpack("N")[0]
      payload = io.remote.out.read(payload_length)
    end

    after :example do
      @thread.kill
    end

    [3].each do |version|
      context "when remote protocol version is #{version}" do
        let(:version){ version }
        let(:version_class){ HrrRbSftp::Protocol.const_get(:"Version#{version}") }

        let(:pkt_args){
          [
            {:version => version},
          ]
        }

        context "when responding to extended request" do
          let(:extended_payload){
            version_class::Packets::SSH_FXP_EXTENDED.new(*pkt_args).encode(extended_packet)
          }

          context "with statvfs@openssh.com extended-request" do
            let(:extended_packet){
              {
                :"type"             => version_class::Packets::SSH_FXP_EXTENDED::TYPE,
                :"request-id"       => request_id,
                :"extended-request" => extended_request,
                :"path"             => path,
              }
            }
            let(:extended_request){ "statvfs@openssh.com" }

            context "when request is valid" do
              let(:request_id){ 1 }
              let(:path){ "." }
              let(:complementary_packet){
                {:"extended-reply" => "statvfs@openssh.com"}
              }

              it "returns extended-reply response" do
                io.remote.in.write ([extended_payload.bytesize].pack("N") + extended_payload)
                payload_length = io.remote.out.read(4).unpack("N")[0]
                payload = io.remote.out.read(payload_length)
                expect( payload[0].unpack("C")[0] ).to eq version_class::Packets::SSH_FXP_EXTENDED_REPLY::TYPE
                packet = version_class::Packets::SSH_FXP_EXTENDED_REPLY.new(*pkt_args).decode(payload, complementary_packet)
                stat = Sys::Filesystem.stat(path)
                expect( packet[:"request-id"] ).to eq request_id
                expect( packet[:"f_bsize"]    ).to eq (stat.block_size)
                expect( packet[:"f_frsize"]   ).to eq (stat.fragment_size)
                expect( packet[:"f_blocks"]   ).to eq (stat.blocks)
                expect( packet[:"f_bfree"]    ).to eq (stat.blocks_free)
                expect( packet[:"f_bavail"]   ).to eq (stat.blocks_available)
                expect( packet[:"f_files"]    ).to eq (stat.files)
                expect( packet[:"f_ffree"]    ).to eq (stat.files_free)
                expect( packet[:"f_favail"]   ).to eq (stat.files_available)
                expect( packet[:"f_fsid"]     ).to eq (stat.filesystem_id)
                expect( packet[:"f_flag"]     ).to eq (stat.flags & (Sys::Filesystem::Stat::RDONLY | Sys::Filesystem::Stat::NOSUID))
                expect( packet[:"f_namemax"]  ).to eq (stat.name_max)
              end
            end

            context "when request path does not exist" do
              let(:request_id){ 1 }
              let(:path){ "path" }

              it "returns status response" do
                io.remote.in.write ([extended_payload.bytesize].pack("N") + extended_payload)
                payload_length = io.remote.out.read(4).unpack("N")[0]
                payload = io.remote.out.read(payload_length)
                expect( payload[0].unpack("C")[0] ).to eq version_class::Packets::SSH_FXP_STATUS::TYPE
                packet = version_class::Packets::SSH_FXP_STATUS.new(*pkt_args).decode(payload)
                expect( packet[:"request-id"] ).to eq request_id
                expect( packet[:"code"]       ).to eq version_class::Packets::SSH_FXP_STATUS::SSH_FX_FAILURE
                expect( packet[:"error message"] ).to eq "statvfs() function failed: No such file or directory"
                expect( packet[:"language tag"]  ).to eq ""
              end
            end

            context "when request path causes other error" do
              let(:request_id){ 1 }
              let(:path){ ("a".."z").to_a.join * 10 }

              it "returns status response" do
                io.remote.in.write ([extended_payload.bytesize].pack("N") + extended_payload)
                payload_length = io.remote.out.read(4).unpack("N")[0]
                payload = io.remote.out.read(payload_length)
                expect( payload[0].unpack("C")[0] ).to eq version_class::Packets::SSH_FXP_STATUS::TYPE
                packet = version_class::Packets::SSH_FXP_STATUS.new(*pkt_args).decode(payload)
                expect( packet[:"request-id"] ).to eq request_id
                expect( packet[:"code"]       ).to eq version_class::Packets::SSH_FXP_STATUS::SSH_FX_FAILURE
                expect( packet[:"error message"] ).to eq "statvfs() function failed: File name too long"
                expect( packet[:"language tag"]  ).to eq ""
              end
            end
          end
        end
      end
    end
  end
end
