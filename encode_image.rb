#!/usr/bin/ruby
# frozen_string_literal: true

# Module to handle errors during process
module ProcessHandler
  # Class to handle non existing params
  class NoParamsError < StandardError
    def message
      "There is no params. #{STANDARD_OUTPUT}"
    end
  end

  # Class to handle unsupported params in input array
  class UnsupportedParam < StandardError
    def message
      "Unsupported param #{ARGUMENTS_ARRAY - @args.keys}"
    end
  end

  # Class to handle BASE64_STRING object
  class BlankString < StandardError
    def message
      "Input base64 string can't be blank! #{STANDARD_OUTPUT}"
    end
  end

  # Class to handle blank PATH in params
  class BlankPath < StandardError
    def message
      "Input path can't be blank! #{STANDARD_OUTPUT}"
    end
  end

  def self.handle_upload(args)
    raise UnsupportedParam if ARGUMENTS_ARRAY.include? ARGUMENTS_ARRAY - args.keys
    raise NoParamsError if args.keys == []
    raise BlankString if BASE64_STRING.nil? && args.key?('b')
    raise BlankPath if PATH.nil? && (args.key?('p') || args.key?('path'))

    encode if ENCODE_PARAMS && PATH
    decode(args) if DECODE_PARAMS && BASE64_STRING
    help if HELP_PARAMS
  end
end

require 'base64'
args = Hash[ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/)]
ARGUMENTS_ARRAY = %w[h help e encode d decode b p path f filename].freeze
BINARY_NAME = File.extname(__FILE__) == '' ? File.basename(__FILE__) : __FILE__
ENCODE_PARAMS = args.key?('encode') || args.key?('e')
DECODE_PARAMS = args.key?('decode') || args.key?('d')
HELP_PARAMS = args.key?('help') || args.key?('h')
FILENAME_PARAMS = args['filename'] || args['f']
PATH = args['path'] || args['p']
BASE64_STRING = args['b']
SUPPORTED_TYPES = %w[png jpg jpeg gif rb php html].freeze
DEFAULT_NAME = 'test_name'
STANDARD_OUTPUT = "Please, type `#{BINARY_NAME} -h` or `#{BINARY_NAME} --help` for help"
USAGE = <<ENDUSAGE
  #{
  if File.extname(__FILE__) != ''
    "For more experience type `chmod +x #{__FILE__} && mv #{__FILE__} /usr/local/bin && #{File.basename(__FILE__, '.*')}`"
  end}
  Usage:
    #{BINARY_NAME} [-h] [decode [-d][--decode] [--path=PATH]] [encode [-e][--encode] [-b=BASE64] [-f=FILENAME][--filename=FILENAME]]
    It's not optional to use quotes in any way for params of params, e.g -b=\"BASE64\" or -f=\"FILENAME\". Instead you can pass values for params without them.
ENDUSAGE

HELP = <<ENDHELP
          Optional params:
              -e,  --encode        Encode param.
              -p=, --path=         Path to file.
              -d,  --decode        Decode param.
              -b=                  Base64 string.
          Not optional params:
              -f=, --filename=     Filename to create after decoding (#{DEFAULT_NAME}.%ext_name% by default).
          Other params:
              -h,  --help          Show this help.

    Example usage:
        #{BINARY_NAME} -e --path=#{Dir.home}/foobar.png #=> SGVsbG8sIHdvcmxkIQ==
        #{BINARY_NAME} -d -b=SGVsbG8sIHdvcmxkIQ==        #=> File has been stored at #{Dir.pwd}/foobar.png
    Supported filetypes:
        #{SUPPORTED_TYPES.join ', '}
ENDHELP

def encode
  base64_file = File.open(PATH, 'rb') do |file|
    Base64.strict_encode64(file.read)
  end
  print base64_file
end

def decode(args)
  img_from_base64 = Base64.decode64(BASE64_STRING)
  img_from_base64[0, 8]
  filetype = (/(png|jpg|jpeg|jfif|gif|rb|php|html)/i.match(img_from_base64[0, 16])[0]).downcase
  filetype = case filetype
             when 'jfif' then 'jpeg'
             else
               filetype
             end
  filename = !FILENAME_PARAMS.nil? ? args['filename'] || args['f'] : DEFAULT_NAME
  file = "#{filename}.#{filetype}"

  File.open(file, 'wb') do |f|
    f.write(img_from_base64)
  end

  print "File has been stored at #{Dir.pwd}/#{file}\n"
end

def help
  print USAGE
  print HELP
end

ProcessHandler.handle_upload(args)
