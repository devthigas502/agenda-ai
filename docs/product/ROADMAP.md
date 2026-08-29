# AgendaAI — Product Roadmap

> Última atualização: 2026-08-29
> **Estratégia:** MVP-first → Iterar com feedback real → Escalar

---

## 🟢 NOW (Sprint 1-3 — MVP Core)

> Objetivo: Entregar um produto funcional para primeiros usuários beta.

| # | Feature | JTBD | Status |
|---|---|---|---|
| F1 | **Cadastro de Profissionais e Serviços** | "Preciso configurar minha agenda com meus profissionais e serviços" | 🔴 Not Started |
| F2 | **Painel Administrativo** | "Preciso gerenciar meus agendamentos no dia a dia" | 🔴 Not Started |
| F3 | **Booking Page (Página Pública)** | "Quero que clientes agendem online 24/7 sem me ligar" | 🔴 Not Started |
| — | **Autenticação & Onboarding** | "Preciso criar minha conta e configurar meu negócio rapidamente" | 🔴 Not Started |
| — | **Multi-tenancy básico** | "Cada negócio precisa de seu espaço isolado" | 🔴 Not Started |

### Definição de MVP Funcional (Pronto para Beta)
- ✅ Um dono de negócio pode se cadastrar
- ✅ Pode configurar profissionais e serviços
- ✅ Recebe uma URL pública para compartilhar
- ✅ Clientes agendam sozinhos pela URL
- ✅ Admin visualiza e gerencia agendamentos no painel

---

## 🟡 NEXT (Sprint 4-6 — Engajamento & Monetização)

> Objetivo: Reduzir no-shows, ativar receita e validar willingness to pay.

| # | Feature | JTBD | Prioridade |
|---|---|---|---|
| F4 | **Notificações (Email + WhatsApp)** | "Quero reduzir no-shows com lembretes automáticos" | Alta |
| F5 | **Pagamento Online** | "Quero cobrar antecipadamente para garantir faturamento" | Alta |
| — | **Sistema de Planos & Billing** | "Preciso cobrar dos clientes após o trial de 14 dias" | Alta |
| — | **Integração Google Calendar** | "Não quero conflitos entre agenda pessoal e profissional" | Média |

---

## 🔵 LATER (Sprint 7+ — Crescimento & Diferenciação)

> Objetivo: Expandir funcionalidades, aumentar retenção e escalar aquisição.

| Feature | Justificativa | Prioridade |
|---|---|---|
| Avaliações e reviews | Social proof para booking page | Média |
| Agendamento recorrente | Sessões semanais (terapia, PT, aulas) | Média |
| Relatórios avançados | Insights de receita, ocupação e performance | Média |
| PWA / App mobile | Acesso rápido para profissionais em movimento | Média |
| Fila de espera | Otimização de horários cancelados | Baixa |
| API pública | Ecossistema de integrações | Baixa |
| IA — sugestão de horários | Diferencial competitivo | Baixa |
| Marketplace público | Descoberta de profissionais por clientes finais | Baixa |

---

## 📊 WSJF Scoring — Priorização do NOW

| Feature | Business Value (1-10) | Time Criticality (1-10) | Opportunity (1-10) | CoD (soma) | Job Size (1-10) | **WSJF** |
|---|---|---|---|---|---|---|
| F1 — Profissionais & Serviços | 10 | 10 | 8 | 28 | 5 | **5.6** |
| F2 — Painel Admin | 9 | 9 | 7 | 25 | 7 | **3.6** |
| F3 — Booking Page | 10 | 10 | 10 | 30 | 6 | **5.0** |
| Autenticação & Onboarding | 10 | 10 | 6 | 26 | 4 | **6.5** |
| Multi-tenancy básico | 8 | 8 | 5 | 21 | 8 | **2.6** |

> **Ordem de desenvolvimento sugerida:** Autenticação → F1 (Profissionais/Serviços) → F3 (Booking Page) → F2 (Painel Admin) → Multi-tenancy

---

## 🎯 Metas de Lançamento

### Beta Privado (Meta: 8 semanas)
- [ ] 10 negócios reais usando a plataforma
- [ ] Taxa de ativação ≥ 70% (cadastro → primeiro agendamento recebido)
- [ ] NPS ≥ 40

### Lançamento Público
- [ ] 100 negócios cadastrados nos primeiros 30 dias
- [ ] Taxa de conversão trial → pago ≥ 15%
- [ ] Taxa de no-show dos clientes com lembretes < 10%

---

## 📐 Análise Competitiva (Referência)

| Competidor | Pontos Fortes | Oportunidade para AgendaAI |
|---|---|---|
| **Calendly** | UX impecável, integrações | Não é focado em serviços locais; sem pagamento integrado no Brasil |
| **SimplyBook.me** | Completo, multi-idioma | Interface confusa, pricing complexo |
| **Agendor** | CRM brasileiro | Não é ferramenta de agendamento puro |
| **Booksy** | Vertical de beleza | Muito nichado; cobra comissão alta |
| **Doctoralia** | Vertical de saúde | Preso ao nicho médico |

**Posicionamento AgendaAI:** Solução genérica, simples e acessível para o mercado brasileiro, com UX moderna, PIX nativo e WhatsApp integrado.
