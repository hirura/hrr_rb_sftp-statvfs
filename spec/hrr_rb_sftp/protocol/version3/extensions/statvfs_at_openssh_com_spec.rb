RSpec.describe HrrRbSftp::Protocol::Version3::Extensions::StatvfsAtOpensshCom do
  it "inherits Extension class" do
    expect( described_class ).to be < HrrRbSftp::Protocol::Version3::Extensions::Extension
  end

  let(:extension_name){ "statvfs@openssh.com" }
  let(:extension_data){ "2" }

  describe "#{described_class}::EXTENSION_NAME" do
    it "is defined" do
      expect(described_class::EXTENSION_NAME).to eq extension_name
    end
  end

  describe "#{described_class}::EXTENSION_DATA" do
    it "is defined" do
      expect(described_class::EXTENSION_DATA).to eq extension_data
    end
  end

  let(:pkt_args){
    [
      {:version => HrrRbSftp::Protocol::Version3::PROTOCOL_VERSION},
    ]
  }

  context "for request" do
    let(:packet){
      {
        :"type"             => HrrRbSftp::Protocol::Version3::Packets::SSH_FXP_EXTENDED::TYPE,
        :"request-id"       => 1,
        :"extended-request" => "statvfs@openssh.com",
        :"path"             => "path",
      }
    }
    let(:payload){
      [
        HrrRbSftp::Protocol::Version3::DataTypes::Byte.encode(packet[:"type"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint32.encode(packet[:"request-id"]),
        HrrRbSftp::Protocol::Version3::DataTypes::String.encode(packet[:"extended-request"]),
        HrrRbSftp::Protocol::Version3::DataTypes::String.encode(packet[:"path"]),
      ].join
    }

    describe "#encode" do
      it "returns payload encoded" do
        expect(HrrRbSftp::Protocol::Version3::Packets::SSH_FXP_EXTENDED.new(*pkt_args).encode(packet)).to eq payload
      end
    end

    describe "#decode" do
      it "returns packet decoded" do
        expect(HrrRbSftp::Protocol::Version3::Packets::SSH_FXP_EXTENDED.new(*pkt_args).decode(payload)).to eq packet
      end
    end
  end

  context "for reply" do
    let(:packet){
      {
        :"type"       => HrrRbSftp::Protocol::Version3::Packets::SSH_FXP_EXTENDED_REPLY::TYPE,
        :"request-id" => 1,
        :"f_bsize"    => 1,
        :"f_frsize"   => 2,
        :"f_blocks"   => 3,
        :"f_bfree"    => 4,
        :"f_bavail"   => 5,
        :"f_files"    => 6,
        :"f_ffree"    => 7,
        :"f_favail"   => 8,
        :"f_fsid"     => 9,
        :"f_flag"     => 0,
        :"f_namemax"  => 255,
      }
    }
    let(:complementary_packet){
      {:"extended-reply" => "statvfs@openssh.com"}
    }
    let(:packet_with_complementary_packet){
      packet.merge(complementary_packet)
    }
    let(:payload){
      [
        HrrRbSftp::Protocol::Version3::DataTypes::Byte.encode(packet[:"type"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint32.encode(packet[:"request-id"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_bsize"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_frsize"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_blocks"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_bfree"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_bavail"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_files"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_ffree"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_favail"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_fsid"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_flag"]),
        HrrRbSftp::Protocol::Version3::DataTypes::Uint64.encode(packet[:"f_namemax"]),
      ].join
    }

    describe "#encode" do
      it "returns payload encoded" do
        expect(HrrRbSftp::Protocol::Version3::Packets::SSH_FXP_EXTENDED_REPLY.new(*pkt_args).encode(packet_with_complementary_packet)).to eq payload
      end
    end

    describe "#decode" do
      it "returns packet decoded" do
        expect(HrrRbSftp::Protocol::Version3::Packets::SSH_FXP_EXTENDED_REPLY.new(*pkt_args).decode(payload, complementary_packet)).to eq packet
      end
    end
  end
end
