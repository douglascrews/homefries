script_echo Python setup...

# Install Python 3.x as needed
which python3 >/dev/null 2>&1 || (echo "Installing Python 3..." && sudo yum -y install python3)

# Install Python 2.x as needed
#which python2 >/dev/null 2>&1 || sudo yum -y install python2

# Install pyenv as needed
[ -d ~/.pyenv ] || curl https://pyenv.run | bash
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install Pip as needed for Python 3.x
#which pip >/dev/null 2>&1 || alias pip=pip.exe
which pip >/dev/null 2>&1 || (echo "Installing pip..." && cd && wget https://bootstrap.pypa.io/get-pip.py && sudo python3 get-pip.py && \rm get-pip.py)
# Get rid of those annoying "you are running an old version of pip" warnings
python -m pip install --upgrade pip >/dev/null 2>&1
# Make sure setuptools is up to date
python -m pip install --upgrade setuptools

#which virtualenv >/dev/null 2>&1 || sudo yum -y install virtualenv
#which virtualenv >/dev/null 2>&1 || alias virtualenv=virtualenv.exe
which virtualenv >/dev/null 2>&1 || (echo "Installing virtualenv..." && pip install virtualenv)
# Debian has its own required virtualenv :(
sudo apt-get -y install python3-venv 2>/dev/null

# PyEnv support
eval "$(pyenv virtualenv-init -)"

venv()
{
	PS1_ORIG=${PS1_ORIG:=${PS1}}
	VENV_NAME=${1:-venv}
	if [ -a ./${VENV_NAME}/bin/activate ]; then
		if [ -n "${VIRTUAL_ENV}" ]; then
			echo "Deactivating...";
			deactivate;
			export PS1="${PS1_ORIG:-${PS1}}"
		else
			if [ -n ./${VENV_NAME}/bin/activate ]; then
				echo "Activating...";
				source ./${VENV_NAME}/bin/activate;
				echo "Using venv ${VIRTUAL_ENV}"
				export PS1="(${VENV_NAME}) ${PS1_ORIG}"
			elif [ -n ./${VENV_NAME}/Scripts/activate ]; then
				echo "Activating...";
				source ./${VENV_NAME}/Scripts/activate;
				echo "Using venv ${VIRTUAL_ENV}"
				export PS1="(${VENV_NAME}) ${PS1_ORIG}"
			else
				echo "ERROR: No executable activate script found in ./${VENV_NAME}"
			fi;
		fi;
	else
		#echo "Converting to Unix...";
		#find . -exec dos2unix {} --quiet --safe \;
		#echo "Converting native Windows back...";
		#find . -name "*.bat" -exec unix2dos --quiet --safe {} \;
		#find . -name "*.cmd" -exec unix2dos --quiet --safe {} \;
		#find . -name "*.ini" -exec unix2dos --quiet --safe {} \;
		echo "Creating...";
		python -m virtualenv ./${VENV_NAME};
		if [ -d ./${VENV_NAME}/Scripts ]; then
			dos2unix --quiet --safe ./${VENV_NAME}/Scripts/activate;
         chmod +x ./${VENV_NAME}/Scripts/activate;
      else
			ln -s ./${VENV_NAME}/bin ./${VENV_NAME}/Scripts 2>/dev/null
		fi
		# Look for Linux version first
		if [ -n ./${VENV_NAME}/bin/activate ]; then
			source ./${VENV_NAME}/bin/activate
		elif [ -n ./${VENV_NAME}/Scripts/activate ]; then
			source ./${VENV_NAME}/Scripts/activate
		else
			echo "ERROR: No activate script found in ./${VENV_NAME}"
		fi
		# First time, the PS1 prompt is fucked up
		export PS1="(${VENV_NAME}) ${PS1_ORIG}"
	fi;
}
#which venv

python_setup()
{
	if [ ! -n "${VIRTUAL_ENV}" ]; then
		venv
	fi
	pip install -r requirements.txt
}

#echo ${PYTHONPATH} | grep "\.:" >/dev/null 2>&1 || export PYTHONPATH=.:${PYTHONPATH}
echo PYTHONPATH=${PYTHONPATH}

# Default to Python 3.x
which python >/dev/null 2>&1 || alias python=python3
python --version
which pip >/dev/null 2>&1 || alias pip=pip3
pip --version
virtualenv --version
