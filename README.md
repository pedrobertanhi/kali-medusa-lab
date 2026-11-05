# Kali Linux + Medusa: laboratório de força bruta

> Projeto do desafio da DIO sobre ataques de força bruta em ambiente controlado.

A ideia aqui não é atacar sistemas de terceiros. Montei este material para estudar como tentativas repetidas de autenticação funcionam e, principalmente, o que muda quando o serviço recebe proteção de verdade.

O laboratório usa duas máquinas virtuais isoladas:

- **Kali Linux**: máquina de auditoria;
- **Metasploitable 2**: alvo propositalmente vulnerável;
- **DVWA**: aplicação vulnerável usada no cenário web.

## Aviso

Os comandos e listas deste repositório foram preparados apenas para rede interna/host-only e ativos próprios ou autorizados. Não use este conteúdo contra IPs públicos, contas reais ou serviços sem autorização.

## Estrutura

```text
.
├── README.md
├── docs/
│   └── roteiro-do-laboratorio.md
├── wordlists/
│   ├── usuarios-lab.txt
│   └── senhas-lab.txt
└── scripts/
    └── checar-rede-lab.sh
```

## Ambiente

No VirtualBox, deixei as duas VMs na mesma rede **Host-Only**. Um exemplo de endereçamento usado no roteiro:

| Máquina | IP de exemplo | Papel |
|---|---:|---|
| Kali | `192.168.56.10` | auditoria |
| Metasploitable 2 | `192.168.56.20` | alvo |
| DVWA | `192.168.56.30` | aplicação web vulnerável |

Os IPs são exemplos. Antes de qualquer teste, confirme o endereço real no seu ambiente com `ip a` e valide conectividade com `ping -c 2 <IP_DO_ALVO>`.

## O que foi explorado no estudo

1. **FTP** — uso de uma wordlist pequena e do Medusa para entender autenticação por serviço.
2. **DVWA** — automação controlada de tentativa de login no formulário web, com nível de segurança ajustado somente no laboratório.
3. **SMB** — enumeração de contas no alvo de laboratório e password spraying com uma senha por rodada.
4. **Defesa** — bloqueio por tentativas, MFA, senhas fortes, monitoramento e redução de serviços expostos.

O passo a passo está em [docs/roteiro-do-laboratorio.md](docs/roteiro-do-laboratorio.md).

## Ferramentas

- Kali Linux
- Medusa
- Nmap
- smbclient / enum4linux-ng
- curl
- Metasploitable 2
- DVWA
- VirtualBox

## Conclusão

O ponto mais importante para mim foi perceber que o problema não é só ter uma senha fraca. Sem rate limit, bloqueio temporário, alertas e MFA, uma tentativa simples pode virar acesso indevido. Já com controles básicos ativados, o custo do ataque sobe bastante e a detecção fica mais rápida.

## Referências

- [Medusa](http://foofus.net/jmk/medusa/medusa.html)
- [Kali Linux](https://www.kali.org/)
- [Nmap Reference Guide](https://nmap.org/book/man.html)
- [DVWA](https://github.com/digininja/DVWA)
