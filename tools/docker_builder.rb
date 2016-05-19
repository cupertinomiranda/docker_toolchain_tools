require './toolchain.rb'

toolchain = Toolchain.new(:archs_le_elf32)
toolchain.build
