
BUILD = "build"
BINUTILS_BUILD = "#{BUILD}/binutils"

INSTALL_DIR = ENV["INSTALL_DIR"]
SOURCE_DIR = ENV["SOURCE_DIR"]

toolchain_commmands = {
  elf: Proc.new { |params|
    commands = []
    commands.push("mkdir -p #{BINUTILS_BUILD} && cd -p #{BINUTILS_BUILD} ")
  },
  uclibc: Proc.new { |params|

  }
}

FOR_ALL_TARGET_OPTIONS = " \
--strip --rel-rpaths --config-extra \
--with-python=no --no-auto-pull \
--no-auto-checkout --no-native-gdb \
--no-optsize-newlib --no-optsize-libstdc++ \
--no-external-download"

HOST_OPTIONS = "--load 8 --jobs 8"

Toolchain_types = {
  archs_le_elf32: {
    script_options: " #{FOR_ALL_TARGET_OPTIONS} \
	       --elf32 --no-uclibc --no-multilib --cpu archs \
	       --release-name 'docker build #{Time.now}' \
	       --no-pdf"
  },

  arc700_le_linux: {
    script_options: " #{FOR_ALL_TARGET_OPTIONS} \
	       --no-elf32 --uclibc --no-multilib --cpu arc700 \
	       --release-name 'docker build #{Time.now}' \
	       --no-pdf"
  },
}

@@sources = {
  binutils: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/binutils",
      branch: "tls_dev"
    },
  gcc: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/gcc",
      branch: "arc-4.8-dev"
    },
  gdb: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/gdb",
      branch: "arc-7.5-dev"
    },
  linux: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/linux",
      branch: "arc-3.18"
    },
  newlib: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/newlib",
      branch: "arc-2.0-dev"
    },
  toolchain: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/toolchain",
      branch: "arc-dev"
    },
  uClibc: {
      git_repo: "ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/uClibc",
      branch: "arc-mainline-dev"
    },
}


class Toolchain
  def initialize(type, workdir = "/workdir")
    @type = type
    puts "Initializing toolchain building:"
    @install_dir = "#{INSTALL_DIR}/#{type}"
    puts "  install dir: #{@install_dir}"
    @workdir = "#{workdir}/#{type}"
    puts "  workdir dir: #{@workdir}"
    @builddir = "#{@workdir}/build"
    puts "    build dir: #{@builddir}"

    print "Creating directories: "
    `mkdir -p #{@workdir} #{@install_dir} #{@builddir}`
    puts "DONE"

    #print "Uncompressing building content: "
    #`tar -C #{@workdir} build_content.tar.gz`
    #puts "DONE"
  end

  def build
    #puts "Setup environment"
    #environemt_vars = []
    #environemt_vars.push("SOURCE_DIR=#{SOURCE_DIR}")
    #environemt_vars.push("BUILD_DIR=#{@workdir}/build")
    #environemt_vars.push("INSTALL_DIR=#{@install_dir}")
    #environemt_vars.push("PATH=#{@install_dir}/bin:#{ENV["PATH"]}")
    #environemt_vars = environemt_vars.join(" ")

    Toolchain::get_sources

    puts "Copying toolchain scripts and making links ... "
    `cp -aHf #{SOURCE_DIR}/toolchain #{@workdir}`
    `ln -sf #{SOURCE_DIR}/binutils #{@workdir}`
    `ln -sf #{SOURCE_DIR}/gdb #{@workdir}`
    `ln -sf #{SOURCE_DIR}/gcc #{@workdir}`
    `ln -sf #{SOURCE_DIR}/newlib #{@workdir}`
    `ln -sf #{SOURCE_DIR}/uClibc #{@workdir}`
    `ln -sf #{SOURCE_DIR}/linux #{@workdir}`
    puts "DONE"

    
    puts "Building ... "
    cmd = ["cd #{@workdir}/toolchain && ./build-all.sh"]
    cmd.push("--build-dir #{@builddir}")
    cmd.push("--install-dir #{@install_dir}")
#    cmd.push("--source-dir #{SOURCE_DIR}")
    cmd.push(Toolchain_types[@type][:script_options])
    cmd = cmd.join(" ")
    puts "  executing: #{cmd}"
    #puts `#{cmd}`
    exec = IO.popen(cmd)
    @pid = exec.pid
    exec.each do |line| 
      puts "-- #{line}"
    end
    exec.close
    puts "DONE"
  end

  def Toolchain::get_sources
    return if File.exists?(SOURCE_DIR)
    puts "Getting sources"
    `mkdir -p #{SOURCE_DIR}`
    Dir.chdir(SOURCE_DIR)
    @@sources.each_pair do |name, data|
      puts " -- downloading #{name} from #{data[:git_repo]} (branch #{data[:branch]})"
      `git clone --depth 1 --branch #{data[:branch]} #{data[:git_repo]} #{name}`
    end
  end

  
end
