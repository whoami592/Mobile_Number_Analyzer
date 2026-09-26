#!/usr/bin/env ruby
# encoding: UTF-8
require 'json'
require 'optparse'
require 'time'

module MobileAnalyzer
  CREDIT = 'Coded by Cyber Security Engineer Mr Sabaz Ali Khan'.freeze
  # Small explicit lookup table, not a complete global numbering database.
  CODES = {'92'=>'Pakistan', '91'=>'India', '93'=>'Afghanistan',
           '971'=>'United Arab Emirates', '966'=>'Saudi Arabia',
           '965'=>'Kuwait', '974'=>'Qatar', '968'=>'Oman',
           '973'=>'Bahrain', '880'=>'Bangladesh', '44'=>'United Kingdom / shared territories',
           '1'=>'North American Numbering Plan (shared code)'}.freeze
  NOTICE = 'Offline format analysis only. No GPS, owner, CNIC, current carrier, active-SIM or account lookup.'.freeze

  def self.analyze(input, pakistan: false)
    value = input.to_s.strip
    raise ArgumentError, 'Enter a number.' if value.empty?
    raise ArgumentError, 'Number is too long.' if value.length > 80
    raise ArgumentError, 'Use digits, +, spaces, parentheses and hyphens only.' unless value.match?(/\A[0-9+ ()-]+\z/)
    compact = value.gsub(/[ ()-]/, '')
    compact = '+' + compact[2..-1] if compact.start_with?('00')
    if pakistan && compact.match?(/\A03[0-9]{9}\z/)
      compact = '+92' + compact[1..-1]
    end
    raise ArgumentError, 'Use +countrycode followed by number; for 03... choose Pakistan mode.' unless compact.match?(/\A\+[1-9][0-9]{1,14}\z/)
    digits = compact[1..-1]
    code = CODES.keys.sort_by { |key| -key.length }.find { |key| digits.start_with?(key) }
    national = code ? digits[code.length..-1] : nil
    status = if code == '92'
      national.match?(/\A3[0-6][0-9]{8}\z/) ? 'Matches Pakistan mobile pattern (2021 plan)' : 'Does not match bundled Pakistan mobile pattern; other types/new allocations not assessed'
    else
      'National number format not assessed'
    end
    {
      normalized: compact,
      international_syntax: 'Pass (syntax only, not proof of a real number)',
      calling_code: code ? '+' + code : 'Not in bundled lookup table',
      numbering_region: code ? CODES[code] : 'Unknown; not proof of invalidity',
      national_digits: national,
      mobile_format: status,
      current_location: 'Unavailable; numbering region is not current location',
      notice: NOTICE,
      analyzed_at_utc: Time.now.utc.iso8601,
      credit: CREDIT
    }
  end

  def self.display(result)
    puts '\n--- ANALYSIS ---'.sub('\\n', "\n")
    result.each { |key, value| puts "#{key.to_s.tr('_', ' ').capitalize}: #{value}" unless value.nil? }
  end

  def self.save(result, path)
    # Exclusive creation prevents accidentally replacing an existing file.
    File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0600) do |file|
      file.write(JSON.pretty_generate(result) + "\n")
    end
  end

  def self.run(argv)
    options = {}
    parser = OptionParser.new do |p|
      p.banner = 'Usage: ruby mobile_analyzer.rb [--pk] [--json] [--save FILE] [NUMBER]'
      p.on('--pk', 'Allow Pakistan local mobile format 03xxxxxxxxx') { options[:pk] = true }
      p.on('--json', 'Print JSON only; requires NUMBER') { options[:json] = true }
      p.on('--save FILE', 'Save JSON report to a NEW file') { |file| options[:save] = file }
      p.on('-h', '--help', 'Show help') { puts p; return 0 }
    end
    parser.parse!(argv)
    raise ArgumentError, 'Supply one number, quoted if it contains spaces.' if argv.length > 1
    if argv.empty?
      raise ArgumentError, '--json and --save require a NUMBER argument.' if options[:json] || options[:save]
      puts "\n=== SABAZ MOBILE NUMBER ANALYZER ===\n#{CREDIT}\n#{NOTICE}\n"
      loop do
        print "\n1. International number\n2. Pakistan local number\n0. Exit\nChoose: "
        choice = $stdin.gets
        break if choice.nil? || choice.strip == '0'
        unless %w[1 2].include?(choice.strip)
          puts 'Choose 1, 2 or 0.'
          next
        end
        print 'Number: '
        number = $stdin.gets
        break if number.nil?
        begin
          display(analyze(number, pakistan: choice.strip == '2'))
        rescue ArgumentError => error
          warn "Input error: #{error.message}"
        end
      end
    else
      result = analyze(argv.first, pakistan: options[:pk])
      options[:json] ? puts(JSON.pretty_generate(result)) : display(result)
      if options[:save]
        save(result, options[:save])
        warn "Report saved to #{options[:save]}"
      end
    end
    0
  rescue OptionParser::ParseError, ArgumentError, SystemCallError => error
    warn "Error: #{error.message}"
    1
  rescue Interrupt
    warn "\nStopped."
    130
  end
end

exit MobileAnalyzer.run(ARGV) if $PROGRAM_NAME == __FILE__
