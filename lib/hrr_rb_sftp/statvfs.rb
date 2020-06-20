module HrrRbSftp

  #
  # hrr_rb_sftp-statvfs is an hrr_rb_sftp extension that supports statvfs@openssh.com and fstatvfs@openssh.com extensions.
  #
  # The following extensions are additionally supported.
  # - statvfs@openssh.com
  # - fstatvfs@openssh.com
  #
  # hrr_rb_sftp-statvfs can be used with hrr_rb_sftp library.
  #
  #   require "hrr_rb_sftp"
  #   require "hrr_rb_sftp/statvfs"
  #
  module Statvfs
  end
end

require "sys/filesystem"
require "hrr_rb_sftp"
require "hrr_rb_sftp/statvfs/version"
require "hrr_rb_sftp/protocol/version3/extensions/statvfs_at_openssh_com"
require "hrr_rb_sftp/protocol/version3/extensions/fstatvfs_at_openssh_com"
