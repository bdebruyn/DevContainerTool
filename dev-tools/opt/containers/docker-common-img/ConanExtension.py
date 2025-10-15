#!/usr/bin/python
from conans import ConanFile, CMake, tools
import os, sys
import subprocess
import pytz
from datetime import datetime, timezone
from tzlocal import get_localzone # $ pip install tzlocal
from string import Template
import os.path
from pathlib import Path
import re

from Colorcodes import Colorcodes
import importlib.util
import sys, inspect

class GitInfo():
    #
    #   Gathers relevant data on the git branch, user and so on
    #
    dev = ''
    branch = ''
    commit = ''
    tag = ''
    timestamp = ''
    name = ''
    version = ''

    def __init__(self, name, version):
        self.conanName = name
        self.conanVersion = version

    def getInfo(self):
        self.commit    = subprocess.getoutput("git rev-parse --short HEAD")
        self.branch    = subprocess.getoutput("git rev-parse --abbrev-ref HEAD")
        self.dev       = subprocess.getoutput("git config user.name")
        self.timestamp = self.getTimestamp()
        self.tag       = self.getTag()

    def getTimestamp(self):
        utc_dt = datetime.now(timezone.utc)
        CST = pytz.timezone('US/Central')
        time = "{}".format(utc_dt.astimezone(CST))
        return time

    def getTag(self):
        tag = subprocess.getoutput("git describe --exact-match --tag")

        if not tag.startswith('fatal:'):
            return tag
        
        return "<no tag>"

    def __str__(self):
        s = ''
        s += self.dev
        s += ', '+self.branch
        s += ', '+self.commit
        s += ', '+self.timestamp
        s += ', '+self.tag
        s += ', '+self.conanName
        s += ', '+self.conanVersion
        return s

class GitVersion():
    #
    #   Code generates the C++ files for including git information into a library
    #   that can be used by applications
    #
    specification  = """#pragma once
#include <string>

class GitVersion
{
   public:
      std::string getInfo()
      {
          return version;
      }
      
      std::string branch { \"$branch\" };
      std::string commit { \"$commit\" };
      std::string dev { \"$dev\" };
      std::string tag { \"$tag\" };
      std::string timestamp { \"$timestamp\" };
      std::string version { \"$version\" };
      std::string conanName { \"$conanName\" };
      std::string conanVersion { \"$conanVersion\" };
};
"""
    implementation = "#include \"GitVersion/GitVersion.h\""
    versionString = "$branch:($commit):$timestamp: $tag $dev: $conanName:$conanVersion"

    def __init__(self, git):
        self.git = git

    def renderSpecification(self):
        v = Template(self.versionString)
        vstr = v.substitute(branch=self.git.branch, commit=self.git.commit, dev=self.git.dev, tag=self.git.tag, timestamp=self.git.timestamp, conanName=self.git.conanName, conanVersion=self.git.conanVersion)
        s = Template(self.specification)
        return s.substitute(branch=self.git.branch, commit=self.git.commit, dev=self.git.dev, tag=self.git.tag, timestamp=self.git.timestamp, conanName=self.git.conanName, conanVersion=self.git.conanVersion, version=vstr)

    def renderImplementation(self):
        return self.implementation

    def writeSpecToFile(self, path):
        with open(path, 'w') as f:
            f.write(self.renderSpecification())

    def writeImplToFile(self, path):
        with open(path, 'w') as f:
            f.write(self.renderImplementation())

class GitVersionCMakeLists():
    #
    #   Code generates the C++ CMakeLists.txt file for compiling the GitVersion C++ class
    #
    cmakeFileContents = """set(target "GitVersion")

message(STATUS "Lib ${target}")

set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
set(source_path  "${CMAKE_CURRENT_SOURCE_DIR}/src")

set(headers
   ${include_path}/GitVersion.h
)

set(sources
   ${source_path}/GitVersion.cpp
)

add_library(${target} STATIC
   ${sources}
   ${headers}
)

target_include_directories(${target}
   PUBLIC
      ${CMAKE_CURRENT_SOURCE_DIR}/include

   PRIVATE
   INTERFACE
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include/${target}>
)

if (SDK)
   target_link_libraries(${target}
      PRIVATE
   
      PUBLIC
      
      INTERFACE
   )
else ()
   target_link_libraries(${target}
      PRIVATE
   
      PUBLIC
      
      INTERFACE
   )
endif ()
    """

    def writeToFile(self, path):
        with open(path, 'w') as f:
            f.write(self.cmakeFileContents)

class GitVersionInstaller():
    #
    #   Creates the directory structure and code generates the C++ code and CMakeLists.txt
    #   files into these directories
    #
    #   Instructions:
    #       To install the GitVersion library, call `makeDir()` method
    #
    rootPath = 'src/GitVersion'
    cmakeFile = rootPath+'/CMakeLists.txt'
    includePath = rootPath+'/include/GitVersion'
    srcPath = rootPath+'/src'
    specFile = includePath+'/GitVersion.h'
    implFile = srcPath+'/GitVersion.cpp'

    def __init__(self, git):
        self.git = git

    def add_subdirectory(self):
        src = "src/CMakeLists.txt"
        contents = ''
        with open(src, "r") as f:
            contents = f.read();

        if "GitVersion" not in contents:
            contents += "\nadd_subdirectory(GitVersion)"
            with open(src, "w") as f:
                f.write(contents)

    def makeDir(self):
        Path(self.includePath).mkdir(parents=True, exist_ok=True)
        Path(self.srcPath).mkdir(parents=True, exist_ok=True)

        cmake = GitVersionCMakeLists()
        cmake.writeToFile(self.cmakeFile);

        gitVersion = GitVersion(self.git)
        gitVersion.writeSpecToFile(self.specFile)
        gitVersion.writeImplToFile(self.implFile)

        self.add_subdirectory()


class Conanfile():
    regexRepoName = '([a-zA-Z0-9_]*-?[a-zA-Z0-9]*)\/([0-9.]*)(\@([a-zA-Z]*)\/([a-zA-Z]*))?' # '([a-zA-Z0-9_]*)(-)?([a-zA-Z0-9]*)'

    def __init__(self, repoName, fileName):
        self.fileName   = fileName
        self.moduleName = self.getModuleNameToConanName(repoName)
        self.conan      = None
        
        if self.moduleName is not None:
            self.loadConanModule()

    def loadConanModule(self):
        #
        # Use python dynamic class loading to instantiate the conan class in the conanfile.py 
        #
        self.spec = importlib.util.spec_from_file_location(self.moduleName, self.fileName)
        self.foo  = importlib.util.module_from_spec(self.spec)
        self.spec.loader.exec_module(self.foo)

        for name, obj in inspect.getmembers(self.foo, inspect.isclass):
            # 
            # There may be more than one class in the conanfile.py
            #
            if name == self.moduleName:
                #
                # We have a name match. Instantiate the conan class
                #
                self.conan = obj.__class__(None)

    def getModuleNameToConanName(self, repoName):
        #
        # legacy naming has capitalization and hypens that make the repo name
        # not an exact match with the class name in the conanfile.py. Use regex
        # to parse the name and convert it to something that is likely to 
        # match.
        #
        parser = re.compile(self.regexRepoName)
        result = parser.match(repoName)
        size   = len(result.groups())

        if size == 1:
            name = result.group(1)
        elif size == 3:
            name = result.group(1).capitalize() + result.group(3).capitalize()
        else:
            print("ERROR: unsupported parsed name: "+repoName)
            return None

        name += 'Conan'
        print('Name='+name)
        return name

class CommandLineOptions():
    filename = '/tmp/CommandLineOptions.txt'

    def __init__(self):
        self.option = None

    def read(self):
        self.option = None

        if os.path.exists(self.filename):
            with open(self.filename,'r') as file:
                for line in file:
                    line = line.strip();
                    self.option = line

class RepoVisitsManager():
    filename = '/tmp/RepoVisits.txt'

    def __init__(self):
        self.repos = []

    def read(self):
        self.repos = []

        if os.path.exists(self.filename):
            with open(self.filename,'r') as file:
                for line in file:
                    line = line.strip();
                    self.repos.append(line)

    def write(self):
        with open(self.filename,'w') as file:
            for repo in self.repos:
                file.write('%s\n' % repo)

    def find(self, repo):
        return any(repo in repoStr for repoStr in self.repos)
        
    def add(self, repo, returncode):
        c = Colorcodes()
        repoStr = f'{c.green}+{repo}{c.reset}' if returncode == 0 else f'{c.red}-{repo}{c.reset}'
        self.repos.append(repoStr)
        self.write()
            
class RepoSource():
    regex = '([a-zA-Z0-9-_]*)\/([0-9]*\.[0-9]*\.[0-9]*)[\@]?([a-zA-Z]*\/[a-zA-Z]*)?'
    repoTag = 'local/stable'
    github = 'git@github.com:bdebruyn/'
    gitlab = ''

    def __init__(self, parent):
        #
        # This field, parent, if not None, indicates the caller is Conan. 
        # If the parent is None, then the caller is this framework.
        #
        self.parent = parent
        self.required = []
        self.parser = re.compile(self.regex)
        self.repoList = RepoVisitsManager()

        clo = CommandLineOptions()
        clo.read()
        self.command = clo.option


    def requires(self, name):
        self.required.append(name)

        if self.parent is not None:
            #
            # self.parent indicates Conan called this method. If the call
            # comes from source, then we are not required to call the "requires"
            # method, otherwise we are required to call the "requires" method.
            #
            self.parent.requires(name)
        else:
            #
            # The framework code is running here, not Conan
            #
            repoName = self.parseName(name)

            if repoName is None:
                print("Skipping "+name)
                return False

            if not self.isRepoExists(repoName):
                #
                # Process the repo only if it doesn't exist already
                #
                if not self.processGitRepo(repoName):
                    return False

                if not self.checkoutIntegrationBranch(repoName):
                    return False

            #
            # For each required repository, run the `conan source .` command so that
            # all of its required repositories are cloned
            #
            print("=================================== Sourcing "+repoName+"===================================")
            task = subprocess.Popen('conan source .', shell=True, cwd='/repo/'+repoName)
            task.wait()
            print("=================================== Done Sourcing "+repoName+"===================================")

            # 
            # Build only have spawning the childred dependencies. Depth-first then breath build
            #
            self.processCommand(repoName)

    def processParent(self, repoName):
        # 
        # Now that all the dependent repos are cloned and built, do the branch checkout on the parent
        # repo and do the build.
        #
        if not self.checkoutIntegrationBranch(repoName):
            return False

        self.processCommand(repoName)

    def processGitRepo(self, repoName):
        #
        # try cloning from github. If that fails, then try gitlab
        #
        result = self.cloneRepo(self.github, repoName)

        if not result:
            print("Failed: "+self.github)
            result = self.cloneRepo(self.gitlab, repoName)

            if not result:
                print("Failed: "+self.gitlab)
                print("ERROR: cannot find Repository: "+repoName+". Giving up")
                return False

        return True

    def checkoutIntegrationBranch(self, repoName):
        integrationBranch = os.environ['BRANCH_INT']
        developmentBranch = os.environ['BRANCH_DEV']

        exitCode, output = subprocess.getstatusoutput("cd /repo/"+repoName+"; git checkout "+developmentBranch)

        if exitCode > 0:
            print("BRANCH_INT="+integrationBranch)
            exitCode, output = subprocess.getstatusoutput("cd /repo/"+repoName+"; git checkout "+integrationBranch)

            if exitCode == 0:
                exitCode, output = subprocess.getstatusoutput("cd /repo/"+repoName+"; git checkout -b "+developmentBranch)
                print("exitCode="+str(exitCode)+", output="+output)
            else:
                print("ERROR: cannot checkout BRANCH_INT="+integrationBranch+". Giving up")
                return False

        return True

    def processCommand(self, repoName):
        returncode = 0
        self.repoList.read();

        if self.repoList.find(repoName):
            print("FOUND: "+repoName+". Skipping compilation")
            return

        directory = self.directory(repoName)

        if self.command is None or self.command == "build":
            returncode = self.buildRepo(directory)
        elif self.command == "deploy":
            self.deploy(director)

        self.repoList.add(repoName, returncode);

    def deploy(self, director):
        pass

    def buildRepo(self, directory):
        conanProfile = os.environ['CONAN_PROFILE']
        print("Profile="+conanProfile)
        
        task = subprocess.Popen(conanProfile, shell=True, cwd=directory)
        task.wait()

        task = subprocess.Popen('conan build .', shell=True, cwd=directory)
        task.wait()
        returncode = task.returncode

        task = subprocess.Popen('export-package.sh', shell=True, cwd=directory)
        task.wait()

        return returncode

    def cloneRepo(self, provider, repoName):
        directory = self.directory(repoName)
        cloneRepoCommand = 'git clone '+provider+repoName+'.git '+directory
        print("Attempt to clone from: "+cloneRepoCommand)
        exitCode, output = subprocess.getstatusoutput(cloneRepoCommand)

        if exitCode > 0:
            print("Clone failed: exitCode="+str(exitCode)+", output="+output)
            return False

        return True

    def parseName(self, name):
        #
        # parse the Conan required repos
        #
        # print("NAME="+name)
        result = self.parser.match(name)
        repoName = result.group(1)
        version  = result.group(2)
        tag      = result.group(3)

        # print("repoName="+repoName)

        # if tag is not None:
        #     print("tag="+tag)

        if tag is None:
            return

        if tag == self.repoTag:
            return repoName

        return None

    def directory(self, repoName):
        return '/repo/'+repoName

    def isRepoExists(self, repoName):
        return os.path.isdir(self.directory(repoName))



class ConanExtension(ConanFile):
    # 
    # User Required Action:
    #   Call self.prePackage() from the derived class from the `def package(self):` method
    #
    #   Example
    #
    #       def package(self):
    #           self.prePackage()
    #           ...
    #           self.copy(*, dst='bin' src=self.build_folder+"/bin", keep_path=False)
    #           self.copy(*, dst='lib' src=self.build_folder+"/lib", keep_path=False)
    #           ...

    settings = "os", "compiler", "build_type", "arch", "arch_build"
    description = "Common Code"
    generators = "cmake"
    options = {
            "shared": [True, False],
            "all_libs_shared": [True, False],
            "sdk": [True, False],
            "unreal": [True, False],
            "gcov": [True, False]
    }
    default_options = { 
            "shared":False, 
            "all_libs_shared":False, 
            "sdk":False,
            "unreal": False,
            "gcov":False
    }
    keep_imports = True
    exports_sources = ["cmake/*", "src/*", "apps/*", "tests/*", "resources/*", "CMakeLists.txt", "run.sh", "!*.sw*", "!*.bin"]

    def __init__(self, output, runner, display_name="", user=None, channel=None):
        super().__init__(output, runner, display_name, user, channel)

    def source(self):
        print("***************************** "+self.__class__.__name__+" **************************************")
        self.preRequirements()
        self.requirements();
        self.repos.processParent(self.name)

    def requirements(self):
        #
        # Placehold for those repos that do not use the requirements method
        #
        pass

    def preRequirements(self, parent=None):
        isReposAttribute = hasattr(self, 'repos')

        if not isReposAttribute:
            setattr(self, "repos", RepoSource(parent))

    def prePackage(self):
        self.setTargetPlatform()
        self.build_folder = self.getBuildFolder()
        self.copy("TestRunner.sh", dst="", src=self.build_folder + "", keep_path=False)

    def getBuildFolder(self):
        return "build-"+str(self.settings.arch) + "-" + str(self.settings.os) + "-" + str(self.settings.build_type)

    def isDeveloperPlatform(self):
        print("settings.arch=="+str(self.settings.arch)+"; settings.os=="+str(self.settings.os))
        return self.settings.arch == "x86_64" and self.settings.os == "Linux"

    def configure_cmake(self):
        cmake = CMake(self, parallel=True)
        cmake.definitions['CMAKE_C_COMPILER_FORCED'] = "TRUE"
        cmake.definitions['CMAKE_CXX_COMPILER_FORCED'] = "TRUE"
        cmake.definitions['CMAKE_TRY_COMPILE_TARGET_TYPE'] = "STATIC_LIBRARY"
        cmake.verbose = True
        return cmake

    def symbolicLinkCompileCommands(self):
        self.build_folder = self.getBuildFolder()
        dst = 'compile_commands.json'
        src = self.build_folder + '/' + dst

        try:
            os.unlink(dst)
        except:
            pass
        os.symlink(src, dst)

    def symbolicLinkBuild(self):
        self.build_folder = self.getBuildFolder()
        dst = 'build'
        src = self.build_folder
        try:
            os.unlink(dst)
        except:
            pass
        os.symlink(src, dst)

    def setCommand(self, f, command):
        print(command)
        f.write(command+'\n')

    def setTargetPlatform(self):
        self.build_folder = self.getBuildFolder()
        filename      = self.build_folder+"/TestRunner.sh"
        #
        arch = str(self.settings.arch)
        arch_package  = arch+"-package"
        #
        ipAddress     = "192.168.10.10"
        commandPrefix = 'sshpass -p "abcd123" ssh -o StrictHostKeychecking=no root@'+ipAddress+' '
        scpPrefix     = 'sshpass -p "abcd123" scp -r '+arch_package+' root@'+ipAddress


    def installGitVersion(self):
        #
        #  Add to self the 'git' attribute having `GitInfo()` object
        #  Instantiate the GitVersion installer and install the C++ GitVersion source code
        #
        setattr(self, "git", GitInfo(self.name, self.version))
        self.git.getInfo()
        libInstaller = GitVersionInstaller(self.git)
        libInstaller.makeDir()

    def build(self):
        self.installGitVersion()

        cmake = self.configure_cmake()

        cmake.definitions['SDK']  = self.options.sdk
        cmake.definitions['UNREAL'] = self.options.unreal
        cmake.definitions['GCOV'] = self.options.gcov

        self.build_folder = self.getBuildFolder()

        self.symbolicLinkCompileCommands()
        self.symbolicLinkBuild()

        self.options['boost'].shared = False
        self.options['gtest'].shared = False

        try:
            self.buildOptions(cmake)
        except AttributeError:
            pass

        cmake.configure()
        retcode = cmake.build()

        if (retcode != 0):
            sys.exit(retcode)
