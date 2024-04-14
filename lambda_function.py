import base64, json, os, matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Attachment, Disposition, FileContent, FileName, FileType, Mail

FROM_EMAIL = "sspswebsite@gmail.com"
TEMPLATE_ID = "d-c792dac8ad5940ee9075aaad5232821c"

SENDGRID_API_KEY = os.environ.get("SENDGRID_API_KEY")

sg = SendGridAPIClient(SENDGRID_API_KEY)

def handler(event, context):    
    os.system("cp -R /var/PFANT /tmp/PFANT")
    os.system("cp -R /var/task/SynSSP_PFANTnew /tmp/SynSSP_PFANTnew")
    os.chdir("/tmp/SynSSP_PFANTnew")
    os.system("link.py --yes")
    
    body = json.loads(event["body"])
    email = body["email"]
    spectra = body["spectra"]
    attachments = []
    
    for spectrum in spectra:
        abundances_1 = spectrum["abundances1"]
        abundances_2 = spectrum["abundances2"]
        abundances_3 = spectrum["abundances3"]

        args = [str(param) for param in [
            spectrum["initialLambda"],
            spectrum["finalLambda"],
            spectrum["deltaLambda"],
            spectrum["age"],
            spectrum["imfType"].lower(),
            spectrum["resolution"],
            spectrum["nms"],
            spectrum["nrg"],
            spectrum["loggcn"],
            
            abundances_1[0],
            abundances_1[1],
            
            abundances_2[0],
            abundances_2[1],
            abundances_2[2],
            abundances_2[3],
            abundances_2[4],
            abundances_2[5],
            abundances_2[6],
            abundances_2[7],
            abundances_2[8],
            abundances_2[9],
            abundances_2[10],
            
            abundances_3[0],
            abundances_3[1],
        ]]
        
        if ("imfSlope" in spectrum and spectrum["imfSlope"] is not None):
            args.append(spectrum["imfSlope"])
        
        os.system(f"Rscript call_synssp.R {' '.join(args)}")

        spectrum_attachment, pdf_attachment = plot_spectrum(f"{'_'.join(args)}")
        
        attachments.append(spectrum_attachment)
        attachments.append(pdf_attachment)
        
    send_email(email, attachments)

def plot_spectrum(name):
    original_path = "/tmp/SynSSP_PFANTnew/st_spectra"
    new_path = f"/tmp/{name}"
    
    os.system(f"cp {original_path} {new_path}")
    
    fig, ax = plt.subplots()

    with open(fr"{original_path}") as spectra:
        x, y = zip(*[[float(number) for number in line.strip().split()] for line in spectra.readlines()[2::]])

    ax.plot(x, y)

    with PdfPages(fr"{new_path}.pdf") as pdf:
        pdf.savefig(fig)
        
    with open(fr"{new_path}", mode="rb") as spectrum:
        encoded_spectrum = base64.b64encode(spectrum.read()).decode()
        
    with open(fr"{new_path}.pdf", mode="rb") as pdf:
        encoded_pdf = base64.b64encode(pdf.read()).decode()

    spectrum_attachment = Attachment(
        FileContent(encoded_spectrum),
        FileName(name),
        FileType("text/plain"),
        Disposition("attachment")
    )

    pdf_attachment = Attachment(
        FileContent(encoded_pdf),
        FileName(f"{name}.pdf"),
        FileType("application/pdf"),
        Disposition("attachment")
    )
    
    return spectrum_attachment, pdf_attachment

def send_email(email, attachments):
    message = Mail(from_email=FROM_EMAIL, to_emails=email)

    message.template_id = TEMPLATE_ID
    message.attachment = attachments

    sg.send(message)
