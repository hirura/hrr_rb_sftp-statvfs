module HrrRbSftp
  module Statvfs
  end
end

require "sys/filesystem"
require "hrr_rb_sftp"
require "hrr_rb_sftp/statvfs/version"
require "hrr_rb_sftp/protocol/version3/extensions/statvfs_at_openssh_com"
require "hrr_rb_sftp/protocol/version3/extensions/fstatvfs_at_openssh_com"
