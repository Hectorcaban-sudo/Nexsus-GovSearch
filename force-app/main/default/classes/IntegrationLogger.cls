/**
 * Lightweight logger that writes to Integration_Log__c and System.debug.
 */
public with sharing class IntegrationLogger {
    public static void info(String source, String message) {
        log('INFO', source, message);
    }

    public static void warn(String source, String message) {
        log('WARN', source, message);
    }

    public static void error(String source, String message) {
        log('ERROR', source, message);
    }

    public static void error(String source, Exception e) {
        String msg = e.getMessage() + '\n' + e.getStackTraceString();
        log('ERROR', source, msg);
    }

    private static void log(String level, String source, String message) {
        System.debug('[' + level + '] ' + source + ': ' + message);
        try {
            Integration_Log__c entry = new Integration_Log__c(
                Name = source + ' - ' + Datetime.now().format('yyyy-MM-dd HH:mm:ss'),
                Level__c = level,
                Source__c = source,
                Message__c = message != null && message.length() > 32000 ? message.left(32000) : message
            );
            insert entry;
        } catch (Exception logEx) {
            System.debug('Failed to write Integration Log: ' + logEx.getMessage());
        }
    }
}
