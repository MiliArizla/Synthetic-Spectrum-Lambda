source("stpars.R")
source("pfant12.R")
source("SSP_model.R")

args <- commandArgs(trailingOnly = T)

lmin = as.numeric(args[1])
lmax = as.numeric(args[2])
dl = as.numeric(args[3])
age = as.numeric(args[4])
imf = args[5]
res = as.numeric(args[6]) # fwhm
n_ms = as.numeric(args[7])
n_rg = as.numeric(args[8])
logg_cn = as.numeric(args[9])
feh = as.numeric(args[10])
afe = as.numeric(args[11])
cfe = as.numeric(args[12])
nfe = as.numeric(args[13])
ofe = as.numeric(args[14])
mgfe = as.numeric(args[15])
sife = as.numeric(args[16])
cafe = as.numeric(args[17])
tife = as.numeric(args[18])
nafe = as.numeric(args[19])
alfe = as.numeric(args[20])
bafe = as.numeric(args[21])
eufe = as.numeric(args[22])
cfe_rgb = as.numeric(args[23])
nfe_rgb = as.numeric(args[24])

stpars(
  n_ms = n_ms,
  n_rg = n_rg,
  feh = feh,
  afe = afe,
  age = age,
  logg_cn = logg_cn
)

pfant12(
  feh = feh,
  afe = afe,
  lmin = lmin,
  lmax = lmax,
  age = age,
  vt = 2,
  fwhm = res,
  dl = dl,
  CFe = cfe,
  CFe_rgb = cfe_rgb,
  NFe = nfe,
  NFe_rgb = nfe_rgb,
  OFe = ofe,
  MgFe = mgfe,
  SiFe = sife,
  CaFe = cafe,
  TiFe= tife,
  NaFe = nafe,
  AlFe = alfe,
  BaFe = bafe,
  EuFe = eufe,
  n_ms = n_ms,
  n_rg = n_rg,
  logg_cn = logg_cn
)

if (imf == "unimodal") {
  ssp.model(
    feh = feh,
    afe = afe,
    age = age,
    imf = imf,
    slope = as.numeric(args[25]),
    fwhm = res,
    dl = dl,
    CFe = cfe,
    CFe_rgb = cfe_rgb,
    NFe = nfe,
    NFe_rgb = nfe_rgb,
    OFe = ofe,
    MgFe = mgfe,
    SiFe = sife,
    CaFe = cafe,
    TiFe = tife,
    NaFe = nafe,
    AlFe = alfe,
    BaFe = bafe,
    EuFe = eufe,
    n_ms = n_ms,
    n_rg = n_rg,
    logg_cn = logg_cn,
    lmin = lmin,
    lmax = lmax
  )
} else {
  ssp.model(
    feh = feh,
    afe = afe,
    age = age,
    imf = imf,
    fwhm = res,
    dl = dl,
    CFe = cfe,
    CFe_rgb = cfe_rgb,
    NFe = nfe,
    NFe_rgb = nfe_rgb,
    OFe = ofe,
    MgFe = mgfe,
    SiFe = sife,
    CaFe = cafe,
    TiFe = tife,
    NaFe = nafe,
    AlFe = alfe,
    BaFe = bafe,
    EuFe = eufe,
    n_ms = n_ms,
    n_rg = n_rg,
    logg_cn = logg_cn,
    lmin = lmin,
    lmax = lmax
  )
}
