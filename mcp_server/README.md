# 🤖 Agenda AI — Servidor MCP (Python)

Servidor [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) oficial para integração de modelos e agentes de Inteligência Artificial com a plataforma **Agenda AI**.

Este servidor permite que LLMs (como Claude, ChatGPT, Gemini, Antigravity) executem ações diretamente na sua conta do Agenda AI, como **cadastrar novos serviços**.

---

## 🌐 URL de Produção
- **URL Padrão**: `https://agenda-ai-0uu5.onrender.com`

---

## 🛠️ Ferramentas (Tools) Disponíveis

### 1. `cadastrar_servico`
Cadastra um novo serviço na sua conta do Agenda AI.

| Parâmetro | Tipo | Obrigatório | Descrição |
| :--- | :--- | :--- | :--- |
| `nome` | `string` | **Sim** | Nome do serviço (ex: `"Corte Degradê"`, `"Consulta Médica"`, `"Design de Sobrancelha"`). |
| `duracao_minutos` | `int` | **Sim** | Duração do atendimento em minutos (ex: `30`, `45`, `60`). |
| `preco_reais` | `float` | **Sim** | Valor do serviço em Reais (ex: `45.00`, `120.50`). |
| `token` | `string` | Opcional* | Token API gerado pelo usuário. *Pode ser omitido se a variável `AGENDA_AI_API_TOKEN` estiver configurada.* |
| `descricao` | `string` | Opcional | Descrição detalhada do serviço. |
| `ativo` | `bool` | Opcional | Se o serviço está ativo para novos agendamentos (padrão: `true`). |
| `url_base` | `string` | Opcional | URL base da aplicação (padrão: `https://agenda-ai-0uu5.onrender.com`). |

---

### 2. `gerar_token` (Auxiliar)
Gera ou obtém o token de autenticação fornecendo suas credenciais de acesso.

| Parâmetro | Tipo | Obrigatório | Descrição |
| :--- | :--- | :--- | :--- |
| `email` | `string` | **Sim** | E-mail de cadastro da sua conta no Agenda AI. |
| `senha` | `string` | **Sim** | Senha da conta. |

---

## 🔑 Como Obter seu Token de API

Existem duas formas simples de obter o token:

1. **No Painel Web**:
   - Acesse o painel administrativo: [https://agenda-ai-0uu5.onrender.com/admin/settings](https://agenda-ai-0uu5.onrender.com/admin/settings)
   - Na seção **Token de Integração (MCP Server)**, clique em **Copiar Token**.

2. **Via Tool `gerar_token`**:
   - Chame a tool informando seu e-mail e senha.

---

## 🚀 Instalação e Execução

### Pré-requisitos
- Python 3.10 ou superior
- `uv` (recomendado) ou `pip`

### 1. Instalando dependências
```bash
cd /home/thigas/agenda-ai/mcp_server
pip install -r requirements.txt
```

### 2. Executando localmente via stdio
```bash
# Passando o token diretamente como variável de ambiente
export AGENDA_AI_API_TOKEN="seu_token_aqui"
python3 server.py
```

Ou usando o `uv`:
```bash
uv run --with mcp --with httpx python3 /home/thigas/agenda-ai/mcp_server/server.py
```

---

## ⚙️ Configuração em Clientes MCP

### Configuração no Antigravity (`~/.gemini/config/mcp_config.json`)
```json
{
  "mcpServers": {
    "agenda-ai": {
      "command": "python3",
      "args": [
        "/home/thigas/agenda-ai/mcp_server/server.py"
      ],
      "env": {
        "AGENDA_AI_API_TOKEN": "SEU_TOKEN_AQUI",
        "AGENDA_AI_BASE_URL": "https://agenda-ai-0uu5.onrender.com"
      }
    }
  }
}
```

### Configuração no Claude Desktop (`claude_desktop_config.json`)
```json
{
  "mcpServers": {
    "agenda-ai": {
      "command": "python3",
      "args": [
        "/home/thigas/agenda-ai/mcp_server/server.py"
      ],
      "env": {
        "AGENDA_AI_API_TOKEN": "SEU_TOKEN_AQUI"
      }
    }
  }
}
```

---

## 💡 Exemplos de Prompts para o Usuário

Com o servidor conectado, você pode simplesmente pedir ao assistente:

- *"Cadastre um novo serviço de 'Barba Terapia' por R$ 35,00 com duração de 30 minutos."*
- *"Adicione o serviço 'Corte + Barba Premium' no valor de R$ 75,00 durando 60 minutos."*
- *"Gere um token de API com meu e-mail usuario@exemplo.com e cadastre uma 'Massagem Relaxante' por R$ 120,00."*
