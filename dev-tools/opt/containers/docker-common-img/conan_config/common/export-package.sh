RepoDir=$(pwd)
export PYTHONPATH=$PYTHONPATH:$RepoDir
name=$(grep "^[ ]*name[ ]*= \"" conanfile.py | cut -d'=' -f2 | cut -d'"' -f2)
version=$(grep "^[ ]*version[ ]*=" conanfile.py | cut -d'=' -f2 | cut -d'"' -f2)
echo "conan export-pkg . ${name}/${version}@local/stable --force"
conan export-pkg . ${name}/${version}@local/stable --force
