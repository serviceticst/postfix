#!/bin/bash
#------------------------------------------------
#   INSTALACAO AUTOMATIZADA POSTFIX NO ORACLE LINUX 8
#------------------------------------------------
#
#  Desenvolvido por: Service TIC Solucoes Tecnologicas
#            E-mail: contato@servicetic.com.br
#              Site: www.servicetic.com.br
#          Linkedin: https://www.linkedin.com/company/serviceticst
#          Intagram: https://www.instagram.com/serviceticst
#          Facebook: https://www.facebook.com/serviceticst
#           Twitter: https://twitter.com/serviceticst
#           YouTube: https://youtube.com/c/serviceticst
#
#-------------------------------------------------
#
echo "#-----------------------------------------#"
echo    "INFORMAÇÕES SOBRE A CONTA DE E-MAIL"
echo "#-----------------------------------------#"
read -p "Digite o e-mail que fará o envio: " email
read -p "Digite o servidor SMTP: " server
read -p "Digite a porta do servidor SMTP: " porta
read -s -p "Digite a senha do e-mail que fará o envio: " senha
read -p "Digite o e-mail de recebimento do teste: " emailteste
clear
echo "#-----------------------------------------#"
echo            "INSTALANDO POSTFIX"
echo "#-----------------------------------------#"
yum install postfix mailx cyrus-sasl-plain -y
clear
echo "#-----------------------------------------#"
echo       "CONFIGURANDO ARQUIVO MAIN.CF"
echo "#-----------------------------------------#"
mv /etc/postfix/main.cf /etc/postfix/main.cf_bkp
touch /etc/postfix/main.cf
cat <<EOF | tee /etc/postfix/main.cf
#SMTP relayhost
relayhost = [$server]:$porta
# TLS Settings
smtp_tls_loglevel = 1
smtp_use_tls = yes
smtpd_tls_received_header = yes
# TLS
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
queue_directory = /var/spool/postfix
meta_directory = /etc/postfix
setgid_group = postdrop
command_directory = /usr/sbin
sample_directory = /usr/share/doc/postfix/samples
newaliases_path = /usr/bin/newaliases
mailq_path = /usr/bin/mailq
readme_directory = /usr/share/doc/postfix/README_FILES
sendmail_path = /usr/sbin/sendmail
mail_owner = postfix
daemon_directory = /usr/libexec/postfix
manpage_directory = /usr/share/man
html_directory = no
data_directory = /var/lib/postfix
shlib_directory = /usr/lib64/postfix
inet_protocols = ipv4
EOF
clear
echo "#-----------------------------------------#"
echo      "CONFIGURANDO ARQUIVO sasl_passwd"
echo "#-----------------------------------------#"
touch /etc/postfix/sasl_passwd
echo "[$server]:$porta" $email:$senha> /etc/postfix/sasl_passwd
clear
echo "#-----------------------------------------#"
echo          "AJUSTANDO AS PERMISSÕES"
echo "#-----------------------------------------#"
postmap /etc/postfix/sasl_passwd
chmod 644 /etc/postfix/sasl_passwd
chown root:postfix /etc/postfix/sasl_passwd
systemctl restart postfix 
clear
echo "#-----------------------------------------#"
echo         "ENVIANDO E-MAIL DE TESTE"
echo "#-----------------------------------------#"
echo "E-mails de teste." | mail -s "Teste de envio via postfix" -r $email $emailteste
clear
echo "#-----------------------------------------#"
echo        "CONSULTE SUA CAIXA DE E-MAIL"
echo "#-----------------------------------------#"
clear
echo "#-----------------------------------------#"
echo             "VERIFICANDO LOG"
echo "#-----------------------------------------#"
tail -f /var/log/maillog
echo "FIM"
