# This is file is intended to be included
# into actual scripts.

echo_stderr(){
    echo "$*" 1>&2
}

cleanup(){
  rm -rf /tmp/$$*
}
trap cleanup EXIT

error_exit(){
  cleanup
  echo_stderr 'Exiting on error'
}
trap error_exit ERR

HERE=`dirname $0`
HERE=`(cd $HERE/..; pwd)`

LOG(){
  echo_stderr "LOG: $*"
}

ERROR(){
  echo_stderr "Error ($0): $@"
  exit 1
}

get-config(){
  KEY=$1
  sed -n "/^$KEY /s/$KEY *//p" $HERE/config/ec2.config
}

[ -d config ] || ERROR "Script must run the ec2-starter directory"
[ -f config/ec2.config ] || ERROR "missing config/ec2.config, see README"

s3cmd(){
  # odd following odd use of which preempts recursion
  `which s3cmd` --config=$HERE/config/.s3cmd $*
}

make_s3cmd(){
  ACCESS_KEY=`get-config ec2_id`
  SECRET_KEY=`get-config ec2_secret`
  cat <<EOF > config/.s3cmd
[default]
access_key = $ACCESS_KEY
acl_public = False
bucket_location = US
debug_syncmatch = False
default_mime_type = binary/octet-stream
delete_removed = False
dry_run = False
encrypt = False
force = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = 
guess_mime_type = False
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com
human_readable_sizes = False
preserve_attrs = True
proxy_host = 
proxy_port = 0
recv_chunk = 4096
secret_key = $SECRET_KEY
send_chunk = 4096
simpledb_host = sdb.amazonaws.com
use_https = False
verbosity = WARNING
EOF
}


[ -f config/.s3cmd ] || make_s3cmd
[ config/ec2.config -nt config/.s3cmd ] && make_s3cmd
export EC2_CERT=`get-config cert-pem-file`
export EC2_PRIVATE_KEY=`get-config pk-pem-file`
