require_relative 'mobile_analyzer'
require 'tmpdir'
def check(condition, name)
  raise "FAIL: #{name}" unless condition
  puts "PASS: #{name}"
end
result = MobileAnalyzer.analyze('03001234567', pakistan: true)
check(result[:normalized] == '+923001234567', 'Pakistan normalization')
check(result[:mobile_format].start_with?('Matches'), 'Pakistan pattern')
check(MobileAnalyzer.analyze('00923001234567')[:normalized] == result[:normalized], '00 prefix')
check(MobileAnalyzer.analyze('+923991234567')[:mobile_format].start_with?('Does not'), 'Unsupported Pakistan range')
check(MobileAnalyzer.analyze('+12025550123')[:numbering_region].include?('shared'), 'Shared calling code')
['', 'abc', '+92300abc', '03001234567', '++923001234567', '+1234567890123456'].each do |bad|
  rejected = false
  begin
    MobileAnalyzer.analyze(bad)
  rescue ArgumentError
    rejected = true
  end
  check(rejected, "reject #{bad.inspect}")
end
Dir.mktmpdir do |dir|
  path = File.join(dir, 'report.json')
  MobileAnalyzer.save(result, path)
  check(JSON.parse(File.read(path))['normalized'] == result[:normalized], 'JSON round trip')
  rejected = false
  begin
    MobileAnalyzer.save(result, path)
  rescue Errno::EEXIST
    rejected = true
  end
  check(rejected, 'Preserve existing reports')
end
puts 'All checks passed.'
