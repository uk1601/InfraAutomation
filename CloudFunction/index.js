const functions = require('@google-cloud/functions-framework');
var mysql = require('mysql');
functions.cloudEvent('helloPubSub', cloudEvent => {
    console.log(cloudEvent.data);
    const messageData = Buffer.from(cloudEvent.data.message.data, 'base64').toString();
    const { email, userId } = JSON.parse(messageData);

    console.log(`Received verification message for:`);
    console.log(`Email: ${email}`);
    console.log(`User ID: ${userId}`);

    console.log(`Database User: ${process.env.db_user}`);
    console.log(`Database Password: ${process.env.db_password}`);
    console.log(`Database Name: ${process.env.db_host}`);
    console.log("Verification Link: ", `${process.env.verification_link_base_url}/verification?token=${userId}`);
    var verificationUrl = `${process.env.verification_link_base_url}/verification?token=${userId}`;

    var request = require('request');
    var mailData = {
        from: `${process.env.mailgun_from_mail_id}`,
        to: `${email}`,
        subject: 'CSYE Verification Email ',
        text: verificationUrl
    }
    var options = {
        'method': 'POST',
        'url': `${process.env.mailgun_url}`,
        'headers': {
            'Authorization': `Basic ${ process.env.api_key}`
        },
        formData: mailData
    };
    request(options, function (error, response) {
        if (error) throw new Error(error);
        console.log("Mail sent successfully!")
        console.log(response.body);
        // Setup the database connection
        try {
            insertMailLog(email, userId, verificationUrl, 'SUCCESS', '');
        } catch (err) { 
            console.log(err); 
            insertMailLog(email, userId, verificationUrl, 'FAILURE', err);
        }
    });

    function insertMailLog(email, userId, verificationLink, status, errorMessage) {
        var con = mysql.createConnection({
            host: process.env.db_host,
            user: process.env.db_user,
            password: process.env.db_password,
            database: 'webapp'
        });

        con.connect(function (err) {
            if (err) {
                console.error('Database connection error:', err);
                return;
            }
            console.log("Database Connected!");
            var sql = "INSERT INTO MailLog (email, userId, verificationLink, status, errorMessage) VALUES (?, ?, ?, ?, ?)";
            con.query(sql, [email, userId, verificationLink, status, errorMessage], function (err, result) {
                if (err) {
                    console.error('Insert MailLog error:', err);
                } else {
                    console.log("1 record inserted into MailLog");
                }
                con.end();
            });
        });
    }
});
