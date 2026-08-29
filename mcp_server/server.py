#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Servidor MCP em Python para o Agenda AI.
Permite que assistentes e modelos de IA cadastrem serviços no sistema após autenticação por token.

URL Padrão de Produção: https://agenda-ai-0uu5.onrender.com
"""

import os
import sys
import json
import logging
from typing import Optional

try:
    import httpx
except ImportError:
    httpx = None

try:
    from mcp.server.fastmcp import FastMCP
except ImportError:
    FastMCP = None

# Configuração de logging apenas no stderr para não interferir com o protocolo MCP no stdout
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    stream=sys.stderr
)
logger = logging.getLogger("agenda-ai-mcp")

DEFAULT_BASE_URL = os.environ.get("AGENDA_AI_BASE_URL", "https://agenda-ai-0uu5.onrender.com").rstrip("/")
DEFAULT_API_TOKEN = os.environ.get("AGENDA_AI_API_TOKEN")

# Inicialização do FastMCP
if FastMCP is not None:
    mcp = FastMCP(
        "agenda-ai-mcp",
        description="Servidor MCP para cadastro e integração de serviços com o Agenda AI"
    )
else:
    mcp = None


def _make_http_request(method: str, endpoint: str, data: dict = None, token: str = None, base_url: str = None) -> dict:
    """Executa requisição HTTP usando httpx ou urllib como fallback."""
    url = f"{(base_url or DEFAULT_BASE_URL).rstrip('/')}{endpoint}"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    logger.info(f"Fazendo requisição {method} para {url}")

    if httpx is not None:
        with httpx.Client(timeout=30.0) as client:
            if method.upper() == "POST":
                response = client.post(url, json=data, headers=headers)
            else:
                response = client.get(url, headers=headers)

            try:
                res_data = response.json()
            except Exception:
                res_data = {"raw_response": response.text}

            return {
                "status_code": response.status_code,
                "is_success": response.is_success,
                "data": res_data
            }
    else:
        # Fallback usando urllib padrão do Python
        import urllib.request
        import urllib.error

        req_body = json.dumps(data).encode("utf-8") if data else None
        req = urllib.request.Request(url, data=req_body, headers=headers, method=method.upper())

        try:
            with urllib.request.urlopen(req, timeout=30.0) as resp:
                status_code = resp.status
                body = resp.read().decode("utf-8")
                try:
                    res_data = json.loads(body)
                except Exception:
                    res_data = {"raw_response": body}

                return {
                    "status_code": status_code,
                    "is_success": 200 <= status_code < 300,
                    "data": res_data
                }
        except urllib.error.HTTPError as err:
            body = err.read().decode("utf-8")
            try:
                res_data = json.loads(body)
            except Exception:
                res_data = {"error": str(err), "body": body}

            return {
                "status_code": err.code,
                "is_success": False,
                "data": res_data
            }
        except Exception as err:
            return {
                "status_code": 500,
                "is_success": False,
                "data": {"error": str(err)}
            }


if mcp is not None:
    @mcp.tool(
        name="cadastrar_servico",
        description="Cadastra um novo serviço no Agenda AI associado à conta do usuário autenticado."
    )
    def cadastrar_servico(
        nome: str,
        duracao_minutos: int,
        preco_reais: float,
        token: Optional[str] = None,
        descricao: Optional[str] = None,
        ativo: bool = True,
        url_base: Optional[str] = None
    ) -> str:
        """
        Cadastra um novo serviço na plataforma Agenda AI.

        Args:
            nome: Nome do serviço (ex: "Corte Masculino Degradê", "Consulta Geral", "Massagem Relaxante").
            duracao_minutos: Tempo de duração do atendimento em minutos (ex: 30, 45, 60).
            preco_reais: Valor cobrado pelo serviço em Reais (ex: 45.00, 120.50).
            token: Token de autenticação da API gerado pelo usuário no Agenda AI. Se omitido, utiliza a variável de ambiente AGENDA_AI_API_TOKEN.
            descricao: Descrição detalhada do que está incluso no serviço (opcional).
            ativo: Indica se o serviço estará imediatamente disponível para agendamento online (padrão: True).
            url_base: URL da aplicação Agenda AI (opcional, padrão: https://agenda-ai-0uu5.onrender.com).

        Returns:
            Mensagem formatada com o resultado da criação e os detalhes do serviço cadastrado.
        """
        auth_token = token or DEFAULT_API_TOKEN
        if not auth_token:
            return (
                "❌ Erro de Autenticação: Nenhum token de API foi fornecido.\n\n"
                "Para cadastrar um serviço, forneça o parâmetro 'token' ou configure a variável de ambiente "
                "'AGENDA_AI_API_TOKEN'.\n"
                "Você pode visualizar seu token no painel em: Configurações do Negócio (/admin/settings) "
                "ou gerá-lo utilizando a tool 'gerar_token(email, senha)'."
            )

        if not nome or len(nome.strip()) < 2:
            return "❌ Erro de Validação: O nome do serviço deve ter pelo menos 2 caracteres."

        if duracao_minutos <= 0 or duracao_minutos > 480:
            return f"❌ Erro de Validação: A duração deve ser entre 1 e 480 minutos (recebido: {duracao_minutos})."

        if preco_reais < 0:
            return f"❌ Erro de Validação: O preço não pode ser negativo (recebido: {preco_reais})."

        payload = {
            "service": {
                "name": nome.strip(),
                "description": (descricao or "").strip(),
                "duration_minutes": int(duracao_minutos),
                "price_reais": float(preco_reais),
                "currency": "BRL",
                "active": bool(ativo)
            }
        }

        result = _make_http_request(
            method="POST",
            endpoint="/api/v1/services",
            data=payload,
            token=auth_token,
            base_url=url_base
        )

        if result["is_success"]:
            srv = result["data"].get("service", {})
            return (
                f"✅ Serviço '{srv.get('name')}' cadastrado com sucesso no Agenda AI!\n\n"
                f"• ID: {srv.get('id')}\n"
                f"• Nome: {srv.get('name')}\n"
                f"• Duração: {srv.get('formatted_duration', f'{duracao_minutos}min')}\n"
                f"• Preço: {srv.get('formatted_price', f'R$ {preco_reais:.2f}')}\n"
                f"• Status: {'Ativo (disponível para agendamento)' if srv.get('active') else 'Inativo'}\n"
                f"• Descrição: {srv.get('description') or 'Sem descrição'}"
            )
        else:
            errors = result["data"].get("errors") or [result["data"].get("message") or "Erro desconhecido"]
            errors_str = "\n".join([f"- {e}" for e in errors]) if isinstance(errors, list) else str(errors)
            return (
                f"❌ Falha ao cadastrar o serviço (Status HTTP {result['status_code']}):\n"
                f"{errors_str}"
            )

    @mcp.tool(
        name="gerar_token",
        description="Obtém ou gera o token de autenticação de API para um usuário do Agenda AI fornecendo e-mail e senha."
    )
    def gerar_token(
        email: str,
        senha: str,
        url_base: Optional[str] = None
    ) -> str:
        """
        Gera ou recupera o token de autenticação da API para uso nas demais tools.

        Args:
            email: E-mail de cadastro da conta no Agenda AI.
            senha: Senha de acesso da conta.
            url_base: URL da aplicação Agenda AI (opcional, padrão: https://agenda-ai-0uu5.onrender.com).

        Returns:
            Token de API e informações da conta autenticada.
        """
        if not email or not senha:
            return "❌ Erro: Informe e-mail e senha para gerar o token."

        payload = {
            "email": email.strip(),
            "password": senha
        }

        result = _make_http_request(
            method="POST",
            endpoint="/api/v1/auth/token",
            data=payload,
            base_url=url_base
        )

        if result["is_success"]:
            token = result["data"].get("token")
            user = result["data"].get("user", {})
            account = result["data"].get("account", {})
            return (
                f"🔑 Token gerado com sucesso para {user.get('name')} ({user.get('email')})!\n\n"
                f"• Conta: {account.get('name')} (slug: {account.get('slug')})\n"
                f"• Token API: {token}\n\n"
                f"Você pode agora utilizar este token para chamar a tool 'cadastrar_servico' ou configurá-lo "
                f"como variável de ambiente 'AGENDA_AI_API_TOKEN'."
            )
        else:
            msg = result["data"].get("message", "Credenciais inválidas")
            return f"❌ Falha na autenticação (Status HTTP {result['status_code']}): {msg}"


def main():
    if mcp is None:
        sys.stderr.write(
            "Erro: O pacote 'mcp' não está instalado.\n"
            "Instale com: pip install mcp httpx\n"
        )
        sys.exit(1)

    logger.info("Iniciando Agenda AI MCP Server (stdio)...")
    mcp.run()


if __name__ == "__main__":
    main()
