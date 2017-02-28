# at beginning FROM mcr2015b
# to test spm in standalone FROM dspm12
# then with the 2 mcr

FROM thomashirsch/dspm12mcr2


RUN echo "--- START   ----------"

# on monte un volume /rstp_data pour récupérer détarer le dataset et un autre pour mettre le code

VOLUME /rstp_data

VOLUME /rstp_code

ENV DATAROOT=/rstp_data

ENV CODEROOT=/rstp_code

COPY ./rstp_preprocess_wrapper.sh  /rstp_code/rstp_preprocess_wrapper.sh
RUN   /bin/chmod 777  /rstp_code/rstp_preprocess_wrapper.sh

# on va recuperer les executables MSAE de rstp_make batch et post batch. et les lanceurs bash

COPY ./rstp_make_batch  /rstp_code/rstp_make_batch
COPY ./rstp_post_batch  /rstp_code/rstp_post_batch

COPY ./run_rstp_make_batch.sh  /rstp_code/run_rstp_make_batch.sh
COPY ./run_rstp_post_batch.sh  /rstp_code/run_rstp_post_batch.sh

# on recupere aussi le template de batch
COPY ./spm_preprocess_template.m /rstp_code/spm_preprocess_template.m


ENTRYPOINT ["/bin/bash"]



