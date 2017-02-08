FROM mcr2015b

RUN echo "--- START   ----------"

# on monte un volume /rstp pour récupérer détarer le dataset
VOLUME /rstp_data 

COPY ./rstp_preprocess_wrapper.sh  rstp_preprocess_wrapper.sh
RUN   /bin/chmod 777  rstp_preprocess_wrapper.sh

# on doit recuperer l executable MSAE de rstp

ENTRYPOINT ["/bin/bash"]



