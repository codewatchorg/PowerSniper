import jellyfish
import argparse
import re

# Get arguments passed from command line
parser = argparse.ArgumentParser(prog='rockdist.py', 
	formatter_class=argparse.ArgumentDefaultsHelpFormatter,
	description='Get the distances between complex passwords and top passwords used',
	epilog='Example: passdist.py --wordlist rockyou.txt --toplist toplist_rockyou.txt --output analysis.csv --passmin 7 --passmax 12 --complex --passdist 4')
parser.add_argument('--wordlist', 
	required=True,
	help='the file with the complex rockyou passwords')
parser.add_argument('--toplist', 
	required=True,
	help='the file with the top rockyou passwords')
parser.add_argument('--output', 
	default='analysis.csv',
	help='the CSV output of the analysis')
parser.add_argument('--passmin',
	default=7,
	help='the minimum size password to choose from')
parser.add_argument('--passmax',
	default=12,
	help='the maximum size password to choose from')
parser.add_argument('--complex',
	action='store_const',
	const=1,
	default=1,
	help='require complex passwords')
parser.add_argument('--passdist',
	default=4,
	help='the maximum distance between passwords to keep')

# Set defaults if switches aren't used
parser.set_defaults(output='analysis.csv',min=7,max=12,complex=0)

# Stick arguments in a variable
args = vars(parser.parse_args())

# Open file with complex passwords
wordlist = open(args['wordlist'])

# Open file with top passwords
toplist = open(args['toplist'])

# Open output file
output = open(args['output'], 'w')

# Write CSV header
output.write('Top Password,Complex Password,Diff\n')

# Generate a dict of top rockyou passwords
toppasswords = []
for topword in toplist.readlines():

  # Add to toppasswords dict and remove newlines
  toppasswords.append(topword.rstrip("\n\r"))

# Close the list of top passwords as it is no longer needed
toplist.close()

# Generate a dict of rockyou complex passwords
comppasswords = []
for compword in wordlist.readlines():

  # Add to comppasswords dict and remove newlines
  #comppasswords.append(compword.rstrip("\n\r"))

  # Remove new lines
  compword = compword.rstrip("\n\r")

  # Check the size of the password, only add if within range
  if len(compword) >= int(args['passmin']) and len(compword) <= int(args['passmax']):

    # Check whether we are only keeping complex passwords
    if args['complex'] == 1:

      # Compare password to complexity rules of upper and lowercase, numbers, and special characters
      if re.search('[a-z]', compword) and re.search('[A-Z]', compword) and re.search('[0-9]', compword) and re.search("[!@#$%^&*().?/:;<>,\`~\-_+='{}\"\[|]", compword):

        # Add to comppasswords dict if the password is within the range and complex
        comppasswords.append(compword)
    else:

      # Add to comppasswords if within the range and we don't care about complexity
      comppasswords.append(compword)

# Close the password list as it is no longer needed
wordlist.close()

# Loop through the top rockyou passwords
for topword in toppasswords:

  # Look through the complex passwords, comparing against the top rockyou passwords
  for compword in comppasswords:

    # If we can't convert to unicode, move on
    try:

      # Perform Damerau-Levenshtein Distance Comparison
      distance = jellyfish.damerau_levenshtein_distance(unicode(topword), unicode(compword))

      # If the distance is less than or equal to the command line option, then log in report
      if int(distance) <= int(args['passdist']):

        # Output results to file, fixup by escaping double quotes
        output.write('"'+topword.replace('"', '""')+'","'+compword.replace('"', '""')+'",'+str(distance)+'\n')

    except:
      pass

# Close the analysis file
output.close()