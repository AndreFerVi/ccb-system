# 🚀 Instruções Rápidas - CCB System

## ⚡ Setup Rápido

### 1. Executar Script de Configuração
```bash
./setup.sh
```

### 2. Configurar Banco de Dados
```bash
# Conectar ao MySQL
mysql -u root -p

# Executar script SQL
source database/init.sql
```

### 3. Configurar Backend
```bash
cd backend
# Editar config.env com suas credenciais MySQL
nano config.env
# Iniciar servidor
npm run dev
```

### 4. Iniciar Frontend
```bash
# Em outro terminal
flutter run
```

## 🔑 Login Padrão
- **Usuário**: `admin`
- **Senha**: `admin123`

## 📋 Checklist de Verificação

- [ ] Node.js instalado (v16+)
- [ ] Flutter SDK instalado (v3.9.2+)
- [ ] MySQL instalado e rodando
- [ ] Script SQL executado
- [ ] Backend configurado e rodando (porta 3000)
- [ ] Frontend configurado e rodando

## 🛠️ Comandos Úteis

### Backend
```bash
cd backend
npm install          # Instalar dependências
npm run dev         # Desenvolvimento (nodemon)
npm start           # Produção
npm test            # Testes
```

### Frontend
```bash
flutter pub get     # Instalar dependências
flutter run         # Executar app
flutter build web   # Build para web
flutter build apk   # Build para Android
```

### Banco de Dados
```bash
mysql -u root -p    # Conectar ao MySQL
SHOW DATABASES;     # Listar bancos
USE ccb_system;     # Usar banco
SHOW TABLES;        # Listar tabelas
```

## 🐛 Troubleshooting

### Backend não inicia
- Verificar se MySQL está rodando
- Verificar configurações em `config.env`
- Verificar se porta 3000 está livre

### Frontend não conecta
- Verificar se backend está rodando
- Verificar URL da API em `lib/services/api_service.dart`
- Verificar CORS no backend

### Erro de banco de dados
- Verificar credenciais em `config.env`
- Verificar se banco `ccb_system` existe
- Verificar se tabelas foram criadas

## 📞 URLs Importantes

- **Backend**: http://localhost:3000
- **API Docs**: http://localhost:3000/health
- **Frontend**: http://localhost:8080 (web) ou dispositivo mobile

## 🎯 Funcionalidades Principais

1. **Login** - Autenticação com JWT
2. **CRUD Funcionários** - Criar, listar, editar, excluir
3. **Equipamentos** - Gerenciar até 3 equipamentos por funcionário
4. **Estatísticas** - Dashboard com métricas
5. **Validações** - CPF, MAC Address, dados obrigatórios

---

**Sistema pronto para uso! 🎉**
