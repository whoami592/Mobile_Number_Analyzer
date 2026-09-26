# Mobile Number Analyzer
Coded by Cyber Security Engineer Mr Sabaz Ali Khan


On Kali Linux, if Ruby is missing:

    sudo apt update
    sudo apt install ruby
    ruby mobile_analyzer.rb

Windows users can also double-click start_windows.bat.

## Commands
Replace the demonstration input with a number you want to analyze.
The demonstration input is illustrative, not guaranteed to be unassigned.

    ruby mobile_analyzer.rb --pk 03001234567
    ruby mobile_analyzer.rb "+92 300 1234567"
    ruby mobile_analyzer.rb --pk --json 03001234567
    ruby mobile_analyzer.rb --pk --save report.json 03001234567
    ruby mobile_analyzer.rb --help

Reports contain the number entered. Nothing is saved automatically. Existing report
files are never overwritten. Keep reports private. A leading 00 is accepted as an
international-prefix notation; bare international digits require an explicit +.
For example, use +923001234567 rather than 923001234567.

## Features and limits
- Interactive menu, normalized international notation, JSON output and optional export.
- Rejects letters, misplaced + signs and international strings exceeding 15 digits.
- Small calling-code table: Pakistan, India, Afghanistan, UAE, Saudi Arabia, Kuwait,
  Qatar, Oman, Bahrain, Bangladesh, UK/shared territories and NANP/shared region.
- A calling-code match does not validate national length, allocation or subscriber.
- Pakistan local-mode conversion and mobile pattern check use the dated 2021 plan:
  national digits 3[0-6] followed by eight digits. New allocations may differ.
- Other countries receive a calling-code match only, not mobile validation.
- Unknown code means unsupported by this table, not necessarily invalid.
- Does not determine whether a number exists, is active, or has a WhatsApp account.
- Cannot obtain live location, subscriber name, CNIC, address or current carrier.
- A country calling code describes a numbering region, not a person's whereabouts.

## Data references
Pakistan plan, ITU Operational Bulletin 1233 (9 November 2021 notification):
https://www.ituob.org/issues/1233-en/
ITU national numbering plans directory:
https://www.itu.int/oth/t0202
The small table is static and is not a live telecom database.

## Verification
The delivery environment did not have Ruby installed, so Ruby execution could not
be verified there. Run the included checks on your machine:

    
