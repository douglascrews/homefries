#! /bin/sh

if [ ${PWD} = $(\ls --directory ~) ]; then
   echo Do not run this from your home directory. Bad things will happen.
else
   echo Linking scripts to home directory...
   bashfiles=$(find . -name "bashrc*.sh" -o -name "vimrc.sh")
   for f in $(echo $bashfiles); do
      ln -s ${PWD}/$(basename $f) ~/.$(basename --suffix=.sh $f)
   done
   ln -s ./psqlrc.psql ~/.psqlrc
fi

echo Installing hook in ~/.bashrc...
(grep "# DCREWS CUSTOM" ~/.bashrc >/dev/null 2>&1 && echo "Already installed in .bashrc") || \cat _bashrc.sh >> ~/.bashrc
