DIR=`dirname $0`
cd $DIR
MHOME=`pwd`
MODULE=`basename $MHOME`
cd $MHOME
mkdir -p /tmp/startup_flags

LOG(){
    echo "LOG($MODULE `date +%H%M%S`):  $*"
}

ERROR(){
    echo "ERROR($MODULE `date +%H%M%S`):  $*"
    exit 1
}

begin_start_up(){
    if [ "x$MODULE" != "x$1" ] ; then
        ERROR "Module mismatch in begin_start_up $MODULE isn't $1"
    fi
    LOG "Starting $MODULE if necessary ..."
    if [ -f /tmp/startup_flags/$MODULE ] ; then
        LOG "   ... not necessary"
        exit 0
    else
        LOG "   ... $MODULE necessary"
        echo "started `date`" > /tmp/startup_flags/$MODULE
    fi
}

end_start_up(){
    if [ "x$MODULE" != "x$1" ] ; then
        ERROR "Module mismatch in end_start_up $MODULE isn't $1"
    fi
    LOG "Finished starting $1"
    echo "Finished starting $1 `date`" > /tmp/startup_flags/$MODULE
}
 

require(){
   if [ -d ../$1 ] ; then
     if [ -f /tmp/startup_flags/$1 ] ; then
        LOG "$MODULE required $1, it has already started"
     else
        LOG "$MODULE required $1, so starting it now"
        ../$1/start-up.sh
        LOG "returned from starting $1, continue starting $MODULE"
     fi
   else
     ERROR "No such start-up module $1"
   fi
}

install-service(){
  SERVICE=$1
  NAME=$2
  cp -r  $SERVICE /etc/$NAME
  ln -s /etc/$NAME /service/$NAME
}

insert-file-into-root-crontab(){
  P=/tmp/$$.crontab
  cat $1             > $P.bit
  crontab -u root -l > $P.old
  cat $P.old $P.bit  > $P.new
  crontab -u root $P.new
  rm $P.*
}

add-to-root-bin(){
    mkdir -p /root/bin
    mv $* /root/bin/
    if ! grep  --silent /root/bin /etc/bash.bashrc ; then
        echo 'PATH=/root/bin:$PATH' >> /etc/bash.bashrc
    fi
}
