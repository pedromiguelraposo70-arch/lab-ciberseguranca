# Guia de Estudo — Fase 1: Montagem do Laboratório

## 1. O que foi esta fase, em 30 segundos

A construção do próprio laboratório (Entradas #1 a #9): um scan inicial ao Servidor Vulnerável, a instalação do Docker, o arranque e o primeiro acesso ao DVWA, um segundo scan para comparar, e a escolha do primeiro módulo a explorar (SQL Injection, nível Low). Ainda não há ataques nem defesas: há a primeira prova de como a rede isolada do lab se vê a partir do Kali.

## 2. O que se viu na rede

O scan da Entrada #1 encontrou só o SSH. O da Entrada #8, já com o DVWA no ar, encontrou a porta 80 e, sozinho (scripts NSE), o título da aplicação e um cookie de sessão sem a flag `httponly`. Tudo isto de fora, sem credenciais, porque nesta fase não havia nenhuma barreira entre a Kali e o alvo — de propósito, para os exercícios funcionarem. Detalhe em `analise-rede/fase1-construcao-lab.md`.

## 3. Lição

Antes de atacar, ver: um scan diz o que está exposto, e o que um atacante aprende "de graça" antes de tentar qualquer coisa. E o mesmo scan, repetido depois de uma mudança, mostra o que essa mudança acrescentou à superfície exposta.

## Consequência para a organização (síntese da fase, revisão de 2026-10-20)

- Numa empresa, uma aplicação nova posta na rede sem regras de firewall fica visível a quem estiver na mesma rede, com versão e pormenores, antes de alguém decidir se devia estar.
- O primeiro controlo é saber o que se tem exposto: um inventário de serviços (o que a Fase 8 viria a formalizar como inventário de ativos) e um scan antes e depois de cada mudança.
- A rede "toda aberta por defeito" do lab é uma escolha didática; numa organização seria a primeira lacuna de uma auditoria (segmentação e regras de permitir por exceção, como na Fase 9).
