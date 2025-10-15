for file in /opt/java/jdk-16.0.1/bin/*
do
   if [ -x $file ]; then
      filename=`basename $file`
      update-alternatives --install /usr/bin/$filename $filename $file 20000
      update-alternatives --set $filename $file
      echo $file $filename
   fi
   done
