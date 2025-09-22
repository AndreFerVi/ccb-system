# CCB System - Sistema de Cadastro de Funcionários

Sistema completo de autenticação e CRUD de funcionários com Flutter (frontend) e Node.js (backend), utilizando MySQL como banco de dados.

## 🚀 Funcionalidades

### 1. Sistema de Autenticação
- Login com nome de usuário e senha
- Autenticação via JWT (JSON Web Token)
- Senhas protegidas com hash bcrypt
- Controle de sessão persistente

### 2. CRUD de Funcionários
- **Criar**: Cadastro completo de funcionários
- **Listar**: Visualização em tabela com paginação e filtros
- **Atualizar**: Edição de dados já cadastrados
- **Excluir**: Remoção de registros (apenas admins)

### 3. Gestão de Equipamentos
- Cadastro de até 3 equipamentos por funcionário
- Validação de MAC Address único
- Associação automática por CPF

### 4. Validações e Segurança
- Validação de CPF com algoritmo oficial
- Validação de MAC Address
- Verificação de duplicatas
- Rate limiting para prevenir ataques
- CORS configurado

### 5. Estatísticas
- Dashboard com estatísticas por departamento
- Contadores de funcionários e administradores
- Gráficos visuais de distribuição

## 📋 Campos do Funcionário

- **Nome Completo** (obrigatório)
- **Data de Nascimento** (obrigatório, idade entre 16-100 anos)
- **CPF** (obrigatório, único, validado)
- **ADM** (sim/não)
- **UF** (obrigatório)
- **Departamento** (obrigatório)
- **Cargo/Função** (obrigatório)
- **MAC dos Equipamentos** (máximo 3 por CPF)

## 🛠️ Tecnologias Utilizadas

### Backend
- **Node.js** - Runtime JavaScript
- **Express.js** - Framework web
- **MySQL2** - Driver MySQL
- **JWT** - Autenticação
- **bcryptjs** - Hash de senhas
- **Helmet** - Segurança
- **CORS** - Cross-origin requests
- **express-validator** - Validação de dados
- **express-rate-limit** - Rate limiting

### Frontend
- **Flutter** - Framework mobile/web
- **Provider** - Gerenciamento de estado
- **HTTP** - Requisições à API
- **SharedPreferences** - Armazenamento local
- **intl** - Formatação de datas
- **flutter_spinkit** - Loading animations
- **fluttertoast** - Mensagens toast

### Banco de Dados
- **MySQL** - Banco de dados relacional

## 📦 Instalação e Configuração

### Pré-requisitos
- Node.js (v16 ou superior)
- Flutter SDK (v3.9.2 ou superior)
- MySQL (v8.0 ou superior)
- Git

### 1. Configuração do Banco de Dados

```bash
# Conectar ao MySQL
mysql -u root -p

# Executar o script de inicialização
source database/init.sql
```

### 2. Configuração do Backend

```bash
# Navegar para a pasta do backend
cd backend

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp config.env.example config.env

# Editar o arquivo config.env com suas configurações:
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=sua_senha_mysql
# DB_NAME=ccb_system
# JWT_SECRET=sua_chave_secreta_jwt
# PORT=3000
```

### 3. Iniciar o Backend

```bash
# Modo desenvolvimento (com nodemon)
npm run dev

# Modo produção
npm start
```

O backend estará disponível em: `http://localhost:3000`

### 4. Configuração do Frontend

```bash
# Navegar para a pasta raiz do projeto
cd ..

# Instalar dependências do Flutter
flutter pub get

# Executar o aplicativo
flutter run
```

## 🔧 Configuração do Ambiente

### Backend (config.env)
```env
# Configurações do Banco de Dados
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sua_senha_mysql
DB_NAME=ccb_system

# Configurações JWT
JWT_SECRET=sua_chave_secreta_super_forte_aqui
JWT_EXPIRES_IN=24h

# Configurações do Servidor
PORT=3000
NODE_ENV=development

# Configurações de Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### Frontend
O frontend está configurado para conectar com `http://localhost:3000` por padrão. Para alterar, edite o arquivo `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

## 👤 Usuário Padrão

Após executar o script SQL, você pode fazer login com:

- **Usuário**: `admin`
- **Senha**: `admin123`

## 📚 Estrutura do Projeto

```
ccb/
├── backend/
│   ├── config/
│   │   └── database.js
│   ├── middleware/
│   │   ├── auth.js
│   │   └── validation.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── funcionarios.js
│   │   └── equipamentos.js
│   ├── config.env
│   ├── package.json
│   └── server.js
├── database/
│   └── init.sql
├── lib/
│   ├── models/
│   │   ├── user.dart
│   │   ├── funcionario.dart
│   │   └── equipamento.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── auth_service.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── funcionarios_screen.dart
│   │   ├── equipamentos_screen.dart
│   │   └── stats_screen.dart
│   ├── widgets/
│   │   ├── custom_text_field.dart
│   │   ├── funcionario_card.dart
│   │   ├── funcionario_form_dialog.dart
│   │   ├── equipamento_card.dart
│   │   └── loading_overlay.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## 🔌 Endpoints da API

### Autenticação
- `POST /api/auth/login` - Login
- `GET /api/auth/verify` - Verificar token
- `POST /api/auth/logout` - Logout

### Funcionários
- `GET /api/funcionarios` - Listar funcionários
- `GET /api/funcionarios/:id` - Buscar funcionário
- `POST /api/funcionarios` - Criar funcionário
- `PUT /api/funcionarios/:id` - Atualizar funcionário
- `DELETE /api/funcionarios/:id` - Excluir funcionário (admin)
- `GET /api/funcionarios/stats/departamentos` - Estatísticas

### Equipamentos
- `GET /api/equipamentos` - Listar equipamentos
- `GET /api/equipamentos/:id` - Buscar equipamento
- `POST /api/equipamentos` - Criar equipamento
- `PUT /api/equipamentos/:id` - Atualizar equipamento
- `DELETE /api/equipamentos/:id` - Excluir equipamento

## 🛡️ Segurança

### Backend
- Senhas hasheadas com bcrypt
- JWT para autenticação
- Rate limiting para prevenir ataques
- Validação de entrada com express-validator
- CORS configurado
- Helmet para headers de segurança

### Frontend
- Validação de formulários
- Sanitização de dados
- Armazenamento seguro de tokens
- Tratamento de erros

## 🧪 Validações Implementadas

### CPF
- Algoritmo oficial de validação
- Verificação de dígitos verificadores
- Prevenção de CPFs inválidos (111.111.111-11, etc.)

### MAC Address
- Formato válido (XX:XX:XX:XX:XX:XX)
- Unicidade no sistema
- Máximo 3 por funcionário

### Dados do Funcionário
- Nome: mínimo 2 caracteres
- Idade: entre 16 e 100 anos
- UF: sigla válida de 2 caracteres
- Departamento e cargo: obrigatórios

## 🚀 Deploy

### Backend
1. Configure as variáveis de ambiente para produção
2. Instale as dependências: `npm install --production`
3. Execute: `npm start`

### Frontend
1. Configure a URL da API para produção
2. Execute: `flutter build web` ou `flutter build apk`

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Suporte

Para dúvidas ou problemas, abra uma issue no repositório.

---

**Desenvolvido com ❤️ para o sistema CCB**