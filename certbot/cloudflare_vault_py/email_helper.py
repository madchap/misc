import smtplib
from smtplib import SMTPException

sender = 'helmsdeep@darthgibus.net'

def send_email(recipient, body, sender=sender):
    try:
        smtp_obj = smtplib.SMTP(host='127.0.0.1', port=25)
        smtp_obj.sendmail(sender, recipient, body)
        print("Email sent to {}".format(recipient))
    except SMTPException as e:
        print("Error sending email to {}".format(recipient))
        print(str(e))
