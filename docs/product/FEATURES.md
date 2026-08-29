# AgendaAI — Feature Specification (JTBD)

> **Visão do Produto:** Uma plataforma SaaS de agendamento genérica que permite a qualquer negócio oferecer reservas online de forma simples, automatizada e profissional.

---

## 🎯 Público-Alvo

| Segmento | Descrição |
|---|---|
| **Primário** | Qualquer negócio baseado em serviços que precise de agendamento (clínicas, salões, consultorias, academias, estúdios, freelancers, etc.) |
| **Secundário** | Clientes finais que agendam serviços (consumidores) |

---

## 💰 Modelo de Monetização

| Aspecto | Decisão |
|---|---|
| **Modelo** | Apenas planos pagos com trial gratuito |
| **Trial** | 14 dias com acesso completo |
| **Planos** | Starter → Professional → Business (definição de limites por plano em fase posterior) |

---

## 📋 Features — Formato JTBD

### F1: Cadastro de Profissionais e Serviços

> **Quando** eu estou configurando meu negócio pela primeira vez,
> **Eu quero** cadastrar meus profissionais e os serviços que cada um oferece (nome, duração, preço),
> **Para que** meus clientes possam ver exatamente o que ofereço e escolher o profissional/serviço adequado.

**Critérios de Aceitação:**
- [ ] Dono do negócio pode criar, editar e desativar profissionais
- [ ] Cada profissional pode ter múltiplos serviços vinculados
- [ ] Cada serviço possui: nome, descrição, duração (em minutos), preço
- [ ] Profissionais podem definir seus horários de disponibilidade (dias da semana + horários)
- [ ] Suporte a pausas e bloqueios de horário (almoço, folga, férias)

**Métricas de Sucesso:**
- ≥ 80% dos usuários em trial completam o cadastro de pelo menos 1 profissional e 1 serviço nas primeiras 24h

---

### F2: Painel Administrativo

> **Quando** eu preciso gerenciar o dia a dia da minha agenda,
> **Eu quero** um painel centralizado com visão de calendário e lista de agendamentos,
> **Para que** eu tenha controle total sobre meus compromissos, reduza faltas e organize minha operação.

**Critérios de Aceitação:**
- [ ] Visualização de agenda em formato: dia, semana e mês
- [ ] Filtro por profissional
- [ ] Criação manual de agendamento (pelo admin)
- [ ] Cancelamento e reagendamento de compromissos
- [ ] Status dos agendamentos: Pendente → Confirmado → Concluído / Cancelado / No-Show
- [ ] Dashboard com métricas resumidas: total agendamentos, taxa de cancelamento, receita estimada

**Métricas de Sucesso:**
- Tempo médio para encontrar um agendamento específico < 5 segundos
- ≥ 90% das operações diárias resolvidas sem sair do painel

---

### F3: Página Pública de Agendamento (Booking Page)

> **Quando** um cliente quer agendar um serviço comigo,
> **Eu quero** compartilhar um link público onde ele possa ver meus serviços, horários disponíveis e reservar sozinho,
> **Para que** eu não precise atender telefonemas/mensagens e o cliente agende 24/7 com autonomia.

**Critérios de Aceitação:**
- [ ] URL pública personalizável (`agendaai.com.br/nome-do-negocio`)
- [ ] Exibição dos serviços disponíveis com preço e duração
- [ ] Seleção de profissional (se aplicável)
- [ ] Calendário interativo mostrando apenas horários disponíveis em tempo real
- [ ] Formulário de dados do cliente (nome, email, telefone)
- [ ] Confirmação visual do agendamento com resumo
- [ ] Design responsivo (mobile-first)

**Métricas de Sucesso:**
- Taxa de conversão da página ≥ 40% (visitante → agendamento concluído)
- Tempo médio para completar um agendamento < 2 minutos

---

### F4: Notificações (Email & WhatsApp)

> **Quando** um agendamento é criado, está se aproximando ou é alterado,
> **Eu quero** que tanto eu (profissional) quanto o cliente recebamos notificações automáticas,
> **Para que** a taxa de no-show diminua e todos estejam informados sobre mudanças.

**Critérios de Aceitação:**
- [ ] Notificação de confirmação de agendamento (cliente + profissional) — Email
- [ ] Lembrete automático 24h antes — Email e/ou WhatsApp
- [ ] Lembrete automático 1h antes — WhatsApp (opcional)
- [ ] Notificação de cancelamento/reagendamento — Email
- [ ] Templates de mensagem configuráveis pelo dono do negócio
- [ ] WhatsApp via API oficial (Meta Business API) ou integração com provedor (ex: Twilio, Z-API)

**Métricas de Sucesso:**
- Redução da taxa de no-show em ≥ 30% após ativação dos lembretes
- ≥ 95% de entrega de emails (deliverability)

---

### F5: Pagamento Online no Agendamento

> **Quando** um cliente confirma um agendamento,
> **Eu quero** que ele possa pagar antecipadamente (total ou sinal),
> **Para que** eu reduza cancelamentos de última hora e garanta meu faturamento.

**Critérios de Aceitação:**
- [ ] Integração com gateway de pagamento (Stripe e/ou Mercado Pago)
- [ ] Opções configuráveis: pagamento obrigatório, opcional, ou desabilitado
- [ ] Suporte a pagamento de sinal (percentual do valor total)
- [ ] PIX como método de pagamento (para mercado brasileiro)
- [ ] Política de reembolso configurável pelo dono do negócio
- [ ] Registro de transações no painel administrativo

**Métricas de Sucesso:**
- ≥ 60% dos negócios ativam pagamento online
- Redução de cancelamentos em ≥ 20% quando pagamento antecipado é exigido

---

## 🚀 Features Futuras (Post-MVP)

| Feature | Prioridade | Justificativa |
|---|---|---|
| Multi-tenant completo (subdomínios) | Alta | Escalabilidade e isolamento de dados |
| Integração Google Calendar / Outlook | Alta | Sincronização bidirecional evita conflitos |
| Avaliações e reviews de clientes | Média | Social proof aumenta conversão |
| App mobile nativo (PWA) | Média | Acesso rápido para profissionais |
| Relatórios avançados e analytics | Média | Tomada de decisão baseada em dados |
| Sistema de fila de espera | Baixa | Para horários lotados |
| Agendamento recorrente | Média | Clientes frequentes (ex: terapia semanal) |
| API pública para integrações | Baixa | Permite integrações de terceiros |
| IA para sugestão de horários | Baixa | Diferencial competitivo |
