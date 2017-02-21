# at beginning FROM mcr2015b
# FROM docker_spm12
FROM spmcentral/spm

RUN echo "--- START   ----------"

# on monte un volume /rstp_data pour récupérer détarer le dataset et unn autre pour mettre le code

VOLUME /rstp_data

VOLUME /rstp_code

ENV DATAROOT=/rstp_data

ENV CODEROOT=/rstp_code

COPY ./rstp_preprocess_wrapper.sh  /rstp_code/rstp_preprocess_wrapper.sh
RUN   /bin/chmod 777  /rstp_code/rstp_preprocess_wrapper.sh

# on varecuperer le .m on doit recuperer l executable MSAE de rstp
COPY ./rstp.m  /rstp_code/rstp.m
#RUN   /bin/chmod 777  /rstp_code/rstp

# audessus c l erreur il faut compiler avec spm12 standalone et la mcr


ENTRYPOINT ["/bin/bash"]



