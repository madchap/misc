import smtplib
from smtplib import SMTPException

sender = 'server@darthgibus.net'

def send_email(recipient, message, sender=sender):
    try:
        smtp_obj = smtplib.SMTP('localhost')
        smtp_obj.sendmail(sender, recipient, message)
        print("Email sent to {}".format(recipient))
    except SMTPException:
        print("Error sending email to {}".format(recipient))
