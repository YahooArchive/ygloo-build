#!/bin/sh

retval=0
valgrind="valgrind --error-exitcode=1 --leak-check=yes"

arch=`uname -m | tr '[A-Z]' '[a-z]'`
uname=`uname | tr '[A-Z]' '[a-z]'`

device="native"
prefix="out/target/$uname-$arch/bin/"

APPNAME="$0"
THISDIR=`echo "$APPNAME"|sed 's%/[^/][^/]*$%%'`
if [ "$THISDIR" = "$APPNAME" ]; then
 THISDIR="."
fi
THISDIR=`cd "$THISDIR" && pwd`

topdir="${THISDIR}/../../.."

if [ `which node` ]; then
  NODEJS="node"
elif [ `which nodejs` ]; then
  NODEJS="nodejs"
fi

device="native"
flickr=1

for param in "$@"; do
    if [ "$param" = "android" ]; then
        device="android"
        prefix="/data/local/tmp/"
        adb push "${topdir}/build/tools/valgrind/android.supp" "$prefix/android.supp"
        valgrind="${valgrind} --suppressions=$prefix/android.supp"
    elif [ "$param" = "suppress" ]; then
        valgrind="${valgrind} --suppressions=${topdir}/build/tools/valgrind/known.supp"
    elif [ "$param" = "flickr" ]; then
        flickr=1
    elif [ "$param" = "help" ]; then
        echo "usage: ${0} [android] [unsafe]"
        echo "  android    run on android device using adb"
        echo "  suppress   enable suppressions for known leaks"
        exit 0
    fi
done

#special mac treatment
if [ "$device" != "android" ]; then
    if [ "$uname" = "darwin" ]; then
        valgrind="${valgrind} --suppressions=${topdir}/build/tools/valgrind/macos10.8.supp --dsymutil=yes"
    fi
fi

runTest() {
    cmd="$valgrind $1"

    if [ "$device" = "android" ]; then
        echo "executing on device: $cmd"
        adb shell "$cmd ; "'echo retval=$?' | tee /tmp/$$
        r=`cat /tmp/$$ | sed -n 's/retval=\([0-9]\{1,\}\)/\1/p'`
        rm /tmp/$$
        r=${r%?}
    else
        echo "\n\n\nexecuting locally: $cmd"
        $cmd
        r=$?
    fi

    if [ $r -gt 0 ]; then
        echo "!!!!!!!!!!!!!!!!!!"
        echo "memory leak found by:"
        echo "$cmd"
        echo "!!!!!!!!!!!!!!!!!!"
    fi

    retval=`expr $r + $?`
}


runTest "$prefix/test-yosal"

runTest "$prefix/test-yperwave runtests"
runTest "$prefix/test-yperwave jsonasync"
runTest "$prefix/test-yperwave downloadasync"
runTest "$prefix/test-yperwave demorestart"
runTest "$prefix/test-yperwave demoserial"
runTest "$prefix/test-yperwave demoparallel"
runTest "$prefix/test-yperwave demoget https://www.yahoo.com/"
#runTest "$prefix/test-yperwave demooauth"

runTest "$prefix/ymagine decode -- framework/ymagine/tests/data/theme/grill.jpg"
runTest "$prefix/ymagine decode -shaderName color-bleached -- framework/ymagine/tests/data/theme/grill.jpg"
runTest "$prefix/ymagine effect -width 640 -height 480 'color-sepia;' framework/ymagine/tests/data/theme/grill.jpg /dev/null"
runTest "$prefix/ymagine effect -width 640 -height 480 'vignette-blowout_standard;' framework/ymagine/tests/data/theme/grill.jpg /dev/null"
runTest "$prefix/ymagine convert -width 640 -height 480 framework/ymagine/tests/data/testnv21.yuv /dev/null"
runTest "$prefix/ymagine transcode -force -width 320 -height 240 -- framework/ymagine/tests/data/theme/buffet.jpg /dev/null"
runTest "$prefix/ymagine blur -width 640 -height 480 framework/ymagine/tests/data/theme/buffet.jpg /dev/null"
runTest "$prefix/ymagine sobel -width 640 -height 480 framework/ymagine/tests/data/theme/coffee.jpg /dev/null"


if [ ! -z "$NODEJS" ]; then
  $NODEJS "${topdir}/build/tools/mockserver/mockserver.js" &
  NODEPID=$!
  runTest "$prefix/test-yperwave demosleepwake"
  runTest "$prefix/test-yperwave democancel"
  runTest "$prefix/test-yperwave demotimeout"
  runTest "$prefix/test-yperwave downloadcache"
  runTest "$prefix/test-yperwave diskcache"
  kill $NODEPID
fi

if [ $flickr ]; then
  runTest "$prefix/test-flickr search"
  runTest "$prefix/test-flickr search car"
  runTest "$prefix/test-flickr photoset"
  runTest "$prefix/test-flickr photosetphotos 72157636296933506"
  runTest "$prefix/test-flickr contact"
  runTest "$prefix/test-flickr photos.getcontactsphotos"
  runTest "$prefix/test-flickr people.getgroups"
  runTest "$prefix/test-flickr people.getpublicgroups"
  runTest "$prefix/test-flickr photos.getfavorites 3194993477"
  runTest "$prefix/test-flickr people.getphotos"
  runTest "$prefix/test-flickr interestingness.getList"
  runTest "$prefix/test-flickr photoset.getinfo"
  runTest "$prefix/test-flickr galleries.getlist"
  runTest "$prefix/test-flickr galleries.getlistforphoto"
  runTest "$prefix/test-flickr galleries.getinfo"
  runTest "$prefix/test-flickr photo.getinfo"
  runTest "$prefix/test-flickr group.getinfo"
  runTest "$prefix/test-flickr getphoto-cancel"
  runTest "$prefix/test-flickr photos.getexif"
  runTest "$prefix/test-flickr favorite-photo"
  runTest "$prefix/test-flickr photocache-basic"
  runTest "$prefix/test-flickr login NativeCoder Compile12"
  runTest "$prefix/test-flickr comments.getlist"
  runTest "$prefix/test-flickr photos.people.getlist"
  runTest "$prefix/test-flickr activity.getcontactsphotos"
  runTest "$prefix/test-flickr people.getinfo"
  runTest "$prefix/test-flickr comments.add"
  runTest "$prefix/test-flickr contacts.remove"
  runTest "$prefix/test-flickr contacts.add"
  runTest "$prefix/test-flickr urls.lookupuser"
  runTest "$prefix/test-flickr photosets.addphoto"
  runTest "$prefix/test-flickr photosets.removephotos"
  runTest "$prefix/test-flickr photosets.setprimaryphoto"
  runTest "$prefix/test-flickr groups.pools.getphotos"
  runTest "$prefix/test-flickr groups.pools.add"
  runTest "$prefix/test-flickr groups.pools.remove"
  runTest "$prefix/test-flickr photosetphotos 72157636296933506"
fi



if [ $retval -gt 0 ]; then
    echo "At least 1 leak found!"
    exit $retval
fi

exit $retval

