module HrrRbSftp
  class Protocol
    module Version3
      class Extensions

        #
        # This class implements fstatvfs@openssh.com version 2 extension format and responder.
        #
        class FstatvfsAtOpensshCom < Extension

          #
          # Represents fstatvfs@openssh.com version 2 extension name.
          #
          EXTENSION_NAME = "fstatvfs@openssh.com"

          #
          # Represents fstatvfs@openssh.com version 2 extension data.
          #
          EXTENSION_DATA = "2"

          #
          # Represents fstatvfs@openssh.com version 2 extension read-only flag.
          #
          SSH_FXE_STATVFS_ST_RDONLY = 0x1 # read-only

          #
          # Represents fstatvfs@openssh.com version 2 extension no setuid flag.
          #
          SSH_FXE_STATVFS_ST_NOSUID = 0x2 # no setuid

          #
          # Represents SSH_FXP_EXTENDED packet additional format for fstatvfs@openssh.com version 2 extension.
          #
          REQUEST_FORMAT = {
            :"extended-request" => {
              "fstatvfs@openssh.com" => [
                [DataTypes::String, :"handle"],
              ],
            },
          }

          #
          # Represents SSH_FXP_EXTENDED_REPLY packet additional format for fstatvfs@openssh.com version 2 extension.
          #
          REPLY_FORMAT = {
            :"extended-reply" => {
              "fstatvfs@openssh.com" => [
                [DataTypes::Uint64, :"f_bsize"  ], # file system block size
                [DataTypes::Uint64, :"f_frsize" ], # fundamental fs block size
                [DataTypes::Uint64, :"f_blocks" ], # number of blocks (unit f_frsize)
                [DataTypes::Uint64, :"f_bfree"  ], # free blocks in file system
                [DataTypes::Uint64, :"f_bavail" ], # free blocks for non-root
                [DataTypes::Uint64, :"f_files"  ], # total file inodes
                [DataTypes::Uint64, :"f_ffree"  ], # free file inodes
                [DataTypes::Uint64, :"f_favail" ], # free file inodes for to non-root
                [DataTypes::Uint64, :"f_fsid"   ], # file system id
                [DataTypes::Uint64, :"f_flag"   ], # bit mask of f_flag values
                [DataTypes::Uint64, :"f_namemax"], # maximum filename length
              ],
            },
          }

          #
          # Responds to SSH_FXP_EXTENDED request with fstatvfs@openssh.com extended-request.
          #
          # @param request [Hash{Symbol=>Object}] SSH_FXP_EXTENDED request represented in Hash.
          # @return [Hash{Symbol=>Object}] Response represented in Hash. In case of success, its type is SSH_FXP_EXTENDED_REPLY. In other cases, its type is SSH_FXP_STATUS.
          #
          def respond_to request
            begin
              raise "Specified handle does not exist" unless handles.has_key?(request[:"handle"])
              log_debug { "file = handles[#{request[:"handle"].inspect}]" }
              file = handles[request[:"handle"]]
              log_debug { "Sys::Filesystem.stat(#{file.path.inspect})" }
              stat = Sys::Filesystem.stat(file.path)
              {
                :"type"           => Packets::SSH_FXP_EXTENDED_REPLY::TYPE,
                :"request-id"     => request[:"request-id"],
                :"extended-reply" => request[:"extended-request"], # implied field in reply format
                :"f_bsize"        => stat.block_size,
                :"f_frsize"       => stat.fragment_size,
                :"f_blocks"       => stat.blocks,
                :"f_bfree"        => stat.blocks_free,
                :"f_bavail"       => stat.blocks_available,
                :"f_files"        => stat.files,
                :"f_ffree"        => stat.files_free,
                :"f_favail"       => stat.files_available,
                :"f_fsid"         => stat.filesystem_id,
                :"f_flag"         => stat.flags & (Sys::Filesystem::Stat::RDONLY | Sys::Filesystem::Stat::NOSUID),
                :"f_namemax"      => stat.name_max,
              }
            rescue Sys::Filesystem::Error => e
              log_debug { e.message }
              {
                :"type"          => Packets::SSH_FXP_STATUS::TYPE,
                :"request-id"    => request[:"request-id"],
                :"code"          => Packets::SSH_FXP_STATUS::SSH_FX_FAILURE,
                :"error message" => e.message,
                :"language tag"  => "",
              }
            end
          end
        end
      end
    end
  end
end
