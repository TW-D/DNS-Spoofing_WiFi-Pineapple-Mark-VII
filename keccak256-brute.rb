require('optparse')
require('keccak256')

options = {}
option_parser = OptionParser.new do |opt_parse|
    opt_parse.banner = "Usage: #{__FILE__} [options]"
    opt_parse.on('-d', '--digest DIGEST', 'The target digest.') do |digest|
        options[:digest] = digest
    end
    opt_parse.on('-f', '--file FILE', 'The file including the passwords.') do |file|
        options[:file] = file
    end
    opt_parse.on('-h', '--help', '') do
        puts(opt_parse)
        exit!
    end
    opt_parse.separator('')
    opt_parse.on_tail('Examples:')
    opt_parse.on_tail("\t ruby #{__FILE__} -d b68fe43f0d1a0d7aef123722670be50268e15365401c442f8806ef83b612976b -f ./rockyou.txt")
end
option_parser.order! rescue puts('Missing argument.')

if (options[:file] and options[:digest])
    begin
        File.readlines(options[:file]).each do |password|
            begin
                password = password.chomp
                digest = Digest::Keccak256.new.hexdigest(password)
                if (digest == options[:digest])
                    puts("[+] #{password}")
                    break
                end
            rescue Exception => exception
            end
        end
    rescue Exception => exception
        puts(exception.message)
    end
else
    puts(option_parser)
end
