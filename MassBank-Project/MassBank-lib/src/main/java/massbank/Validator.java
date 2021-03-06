package massbank;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.petitparser.context.Result;
import org.petitparser.parser.Parser;

/**
 * This class validates a record file or String by using the syntax of {@link RecordParserDefinition}.
 * @author rmeier
 * @version 05-03-2020
 */
public class Validator {
	private static final Logger logger = LogManager.getLogger(Validator.class);
	
	/**
	 * Returns <code>true</code> if there is any suspicious character in <code>recordString</code>.
	 */
	public static boolean hasNonStandardChars(String recordString) {
		// the following are allowed
		char[] myCharSet = new char[] {'–', 'ä', 'ö', 'ü', 'ó', 'é', 'µ', 'á', 'É'};
		Arrays.sort(myCharSet);
		for (int i = 0; i < recordString.length(); i++) {
			if (recordString.charAt(i) > 0x7F &&  (Arrays.binarySearch(myCharSet, recordString.charAt(i))<0)) {
				String[] tokens = recordString.split("\\r?\\n");
				logger.warn("Non standard ASCII character found. This might be an error. Please check carefully.");
				int line = 0, col = 0, offset = 0;
				for (String token : tokens) {
					offset = offset + token.length() + 1;
					if (i < offset) {
						col = i - (offset - (token.length() + 1));
						logger.warn(tokens[line]);
						StringBuilder error_at = new StringBuilder(StringUtils.repeat(" ", tokens[line].length()));
						error_at.setCharAt(col, '^');
						logger.warn(error_at);
						return true;
					}
				line++;
				}
			}
		}
		return false;
	}
	
	/**
	 * Validate a <code>recordString</code> and return the parsed information in a {@link Record} 
	 * or <code>null</code> if the validation was not successful. Be strict in validation.
	 */
	public static Record validate(String recordString, String contributor) {
		return validate(recordString, contributor, true);
	}
	
	/**
	 * Validate a <code>recordString</code> and return the parsed information in a {@link Record} 
	 * or <code>null</code> if the validation was not successful. Be less strict if 
	 * <code>strict</code> is <code>false</code>. This is useful in automatic repair routines.
	 */
	public static Record validate(String recordString, String contributor, boolean strict) {
		Record record = new Record(contributor);
		Parser recordparser = new RecordParser(record, strict);
		Result res = recordparser.parse(recordString);
		if (res.isFailure()) {
			logger.error(res.getMessage());
			int position = res.getPosition();
			String[] tokens = recordString.split("\\n");

			int line = 0, col = 0, offset = 0;
			for (String token : tokens) {
				offset = offset + token.length() + 1;
				if (position < offset) {
					col = position - (offset - (token.length() + 1));
					logger.error(tokens[line]);
					StringBuilder error_at = new StringBuilder(StringUtils.repeat(" ", col));
					error_at.append('^');
					logger.error(error_at);
					break;
				}
				line++;
			}
			return null;
		} 
		return record;
	}

	public static void main(String[] arguments) {
		final Properties properties = new Properties();
		try {
			properties.load(ClassLoader.getSystemClassLoader().getResourceAsStream("project.properties"));
			System.out.println("Validator version: " + properties.getProperty("version"));
			
			if (arguments.length==0) {
				System.out.println("usage: Validator <FILE|DIR> [<FILE|DIR> ...]");
				System.exit(1);
			}
			
			// validate all files in arguments and all *.txt files in directories and subdirectories
			// specified in arguments 
			List<File> recordfiles = new ArrayList<>();
			for (String argument : arguments) {
				File argumentf = new File(argument);
				if (argumentf.isFile() && FilenameUtils.getExtension(argument).equals("txt")) {
					recordfiles.add(argumentf);
				}
				else if (argumentf.isDirectory()) {
					recordfiles.addAll(FileUtils.listFiles(argumentf, new String[] {"txt"}, true));
				}
				else {
					logger.warn("Argument " + argument + " could not be processed.");
				}
			}
			
			logger.trace("Validating " + recordfiles.size() + " files");
		
			AtomicBoolean haserror = new AtomicBoolean(false);
			recordfiles.parallelStream().forEach(filename -> {
				String recordString;
				Record record=null;
				try {
					recordString = FileUtils.readFileToString(filename, StandardCharsets.UTF_8);
					hasNonStandardChars(recordString);
					record = validate(recordString, "");
					if (record == null) {
						logger.error("Error in \'" + filename + "\'.");
						haserror.set(true);
					}
					else {
						logger.trace("validation passed for " + filename);
					}
					
					// validate correct serialisation String -> Record class -> String
					String recordStringFromRecord = record.toString();
					int position = StringUtils.indexOfDifference(new String [] {recordString, recordStringFromRecord});
					if (position != -1) {
						logger.error("Error in \'" + filename + "\'.");
						logger.error("File content differs from generated record string.\nThis might be a code problem. Please Report!");
						String[] tokens = recordStringFromRecord.split("\\n");
						int line = 0, col = 0, offset = 0;
						for (String token : tokens) {
							offset = offset + token.length() + 1;
							if (position < offset) {
								col = position - (offset - (token.length() + 1));
								logger.error("Error in line " + line+1 + ".");
								logger.error(tokens[line]);
								StringBuilder error_at = new StringBuilder(StringUtils.repeat(" ", col));
								error_at.append('^');
								logger.error(error_at);
								break;
							}
							line++;
						}
					}
				} catch (IOException e) {
					e.printStackTrace();
					System.exit(1);
				}
			});
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
