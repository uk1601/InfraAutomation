import winston, { createLogger, format, transport, transports } from 'winston';
const moment = require('moment');

const customJsonFormatter = format((info, opts) => {
  info.severity = info.level.toUpperCase();
  return info;
})();

const logFormat = format.combine(
  format.timestamp({
    format: () => moment().utc().format('YYYY-MM-DDTHH:mm:ssZ') // Ensure timestamp is in UTC
  }),
  format.errors({ stack: true }), 
  format.splat(),
  customJsonFormatter, 
  format.json()
);
const customConsoleLogger = {
  log: (level:any, message:any) => {
    const string = `${moment().utc().format('YYYY-MM-DDTHH:mm:ssZ')} ${level.toUpperCase()}: ${message}`;
    return string;
  }
};

const loggerTransports = [
  new transports.Console({
    level: process.env.LOG_LEVEL || 'info',
    format: format.combine(
      format.colorize(),
      format.printf(({ level, message, timestamp }) => {
        return `${timestamp} ${level.toUpperCase()}: ${message}`;
      })
    ),
  }),
  new transports.File({
    filename: process.env.NODE_ENV == "test"? "/tmp/application.log" : '/var/log/myapp/application.log',
    level: process.env.LOG_LEVEL || 'info',
    format: logFormat, // Apply the custom log format for file transport
  })
];

const logger = createLogger({
  levels: {
    error: 0,
    warn: 1,
    info: 2,
    http: 3,
    verbose: 4,
    debug: 5,
  },
  transports: loggerTransports,
});

export default logger;
