#!/bin/bash

echo "🚀 CCB System - Script de Configuração"
echo "======================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se Node.js está instalado
check_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js encontrado: $NODE_VERSION"
    else
        print_error "Node.js não encontrado. Por favor, instale o Node.js (v16 ou superior)"
        exit 1
    fi
}

# Verificar se Flutter está instalado
check_flutter() {
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_success "Flutter encontrado: $FLUTTER_VERSION"
    else
        print_error "Flutter não encontrado. Por favor, instale o Flutter SDK"
        exit 1
    fi
}

# Verificar se MySQL está instalado
check_mysql() {
    if command -v mysql &> /dev/null; then
        MYSQL_VERSION=$(mysql --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "MySQL encontrado: $MYSQL_VERSION"
    else
        print_error "MySQL não encontrado. Por favor, instale o MySQL"
        exit 1
    fi
}

# Configurar backend
setup_backend() {
    print_status "Configurando backend..."
    
    cd backend
    
    # Instalar dependências
    print_status "Instalando dependências do backend..."
    npm install
    
    if [ $? -eq 0 ]; then
        print_success "Dependências do backend instaladas com sucesso"
    else
        print_error "Falha ao instalar dependências do backend"
        exit 1
    fi
    
    # Criar arquivo de configuração se não existir
    if [ ! -f "config.env" ]; then
        print_status "Criando arquivo de configuração..."
        cat > config.env << EOF
# Configurações do Banco de Dados
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=ccb_system

# Configurações JWT
JWT_SECRET=your_super_secret_jwt_key_here_$(date +%s)
JWT_EXPIRES_IN=24h

# Configurações do Servidor
PORT=3000
NODE_ENV=development

# Configurações de Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF
        print_success "Arquivo config.env criado"
        print_warning "IMPORTANTE: Edite o arquivo backend/config.env com suas configurações de banco de dados"
    else
        print_warning "Arquivo config.env já existe"
    fi
    
    cd ..
}

# Configurar frontend
setup_frontend() {
    print_status "Configurando frontend..."
    
    # Instalar dependências do Flutter
    print_status "Instalando dependências do Flutter..."
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "Dependências do Flutter instaladas com sucesso"
    else
        print_error "Falha ao instalar dependências do Flutter"
        exit 1
    fi
}

# Configurar banco de dados
setup_database() {
    print_status "Configurando banco de dados..."
    
    # Verificar se o MySQL está rodando
    if ! pgrep -x "mysqld" > /dev/null; then
        print_warning "MySQL não está rodando. Por favor, inicie o MySQL antes de continuar"
        print_status "Para iniciar o MySQL:"
        print_status "  - Ubuntu/Debian: sudo systemctl start mysql"
        print_status "  - macOS: brew services start mysql"
        print_status "  - Windows: net start mysql"
        exit 1
    fi
    
    print_status "MySQL está rodando. Agora você precisa executar o script SQL manualmente:"
    print_status "1. Conecte ao MySQL: mysql -u root -p"
    print_status "2. Execute: source database/init.sql"
    print_status "3. Ou copie e cole o conteúdo do arquivo database/init.sql"
}

# Função principal
main() {
    echo ""
    print_status "Verificando pré-requisitos..."
    
    check_nodejs
    check_flutter
    check_mysql
    
    echo ""
    print_status "Iniciando configuração..."
    
    setup_backend
    setup_frontend
    setup_database
    
    echo ""
    print_success "🎉 Configuração concluída!"
    echo ""
    print_status "Próximos passos:"
    print_status "1. Configure o arquivo backend/config.env com suas credenciais do MySQL"
    print_status "2. Execute o script SQL: database/init.sql"
    print_status "3. Inicie o backend: cd backend && npm run dev"
    print_status "4. Em outro terminal, inicie o frontend: flutter run"
    echo ""
    print_status "Credenciais padrão:"
    print_status "  Usuário: admin"
    print_status "  Senha: admin123"
    echo ""
}

# Executar função principal
main
