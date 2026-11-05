# Roteiro do laboratório

## 1. Preparação

No Kali, atualize a base e instale somente o necessário:

```bash
sudo apt update
sudo apt install -y medusa nmap smbclient enum4linux-ng curl
```

Depois confirme que o alvo está acessível pela rede interna:

```bash
ping -c 2 192.168.56.20
nmap -Pn -sV -p 21,80,139,445 192.168.56.20
```

A varredura deve servir apenas para confirmar os serviços previstos no laboratório. Não há motivo para fazer scan amplo nessa prática.

---

## 2. Cenário FTP com Medusa

Usei listas pequenas de propósito, para que o teste fique reproduzível e sem volume desnecessário.

```bash
medusa -h 192.168.56.20 \
  -U wordlists/usuarios-lab.txt \
  -P wordlists/senhas-lab.txt \
  -M ftp -t 1 -f -v 6
```

### O que cada opção faz

| Opção | Uso |
|---|---|
| `-h` | alvo do laboratório |
| `-U` | arquivo de usuários |
| `-P` | arquivo de senhas |
| `-M ftp` | módulo do serviço |
| `-t 1` | uma tentativa paralela; evita sobrecarga |
| `-f` | encerra ao encontrar uma combinação válida |
| `-v 6` | saída detalhada para acompanhar o teste |

### Validação

Quando o Medusa indicar uma combinação válida, a confirmação deve ser feita manualmente e apenas no alvo do laboratório:

```bash
ftp 192.168.56.20
# informar somente a credencial encontrada no cenário
bye
```

O resultado esperado é separar “porta aberta” de “acesso autenticado”: o primeiro mostra exposição do serviço; o segundo prova que a credencial é fraca ou reutilizada.

---

## 3. Cenário web com DVWA

No DVWA, a prática precisa ficar restrita ao ambiente local. Ajuste a segurança da própria aplicação para **Low** somente durante o teste e use a conta de demonstração que acompanha o DVWA.

Primeiro, capture os campos usados pelo formulário:

```bash
curl -I http://192.168.56.30/login.php
```

O fluxo de automação deve respeitar sessão e token CSRF. Por isso, antes de tentar logins, abra a tela no navegador do Kali, entre no DVWA e confira a requisição pelo DevTools/Network. Os campos podem mudar conforme a versão da aplicação.

Exemplo de estrutura de requisição para estudo (substitua somente pelo IP do seu DVWA local e pelos campos observados):

```bash
curl -s -c cookies.txt http://192.168.56.30/login.php > pagina-login.html
# localizar user_token em pagina-login.html e usar o valor na requisição seguinte
```

A automação não deve ser levada para sites reais: formulários atuais normalmente usam tokens, CAPTCHA, rate limit e proteção contra automação. No DVWA isso é justamente parte da lição.

### Validação

- resposta de login muda para área autenticada;
- cookie de sessão é renovado;
- tela do DVWA confirma o usuário autenticado.

---

## 4. Cenário SMB: enumeração e password spraying

Antes de testar senha, confira quais usuários e compartilhamentos o alvo de laboratório expõe:

```bash
enum4linux-ng -A 192.168.56.20
smbclient -L //192.168.56.20 -N
```

Para spraying, a regra é usar **uma senha por rodada** e pouco paralelismo. Isso é diferente de tentar muitas senhas em uma única conta.

```bash
medusa -h 192.168.56.20 \
  -U wordlists/usuarios-lab.txt \
  -p lab123 \
  -M smbnt -t 1 -f -v 6
```

A senha `lab123` existe só como exemplo de laboratório. Caso haja retorno válido, confira o acesso com:

```bash
smbclient //192.168.56.20/<COMPARTILHAMENTO> -U <USUARIO>
```

---

## 5. Medidas de mitigação

| Risco observado | Controle recomendado |
|---|---|
| senhas fáceis ou reaproveitadas | política de senhas, bloqueio de senhas vazadas e gerenciador de senhas |
| muitas tentativas em pouco tempo | rate limiting, atraso progressivo e bloqueio temporário |
| spraying distribuído entre usuários | correlação por IP, ASN, user-agent e padrão de falhas |
| login só com senha | MFA, preferencialmente resistente a phishing |
| SMB/FTP expostos sem necessidade | remover o serviço, restringir por firewall/VPN e segmentar a rede |
| credencial comprometida sem alerta | logs centralizados, alertas de falhas e revisão periódica |

## 6. Lições aprendidas

- Serviço exposto não significa automaticamente invasão, mas amplia muito a superfície de ataque.
- Wordlists pequenas ajudam a entender o fluxo sem transformar o laboratório em teste agressivo.
- Password spraying parece “mais discreto” porque distribui tentativas entre contas; por isso, bloqueio por usuário sozinho não resolve.
- Segurança precisa combinar autenticação forte, limitação de tentativas e visibilidade de logs.
