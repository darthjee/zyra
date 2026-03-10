# Referência de Integração da Gem `zyra`

> **Audiência:** este documento é voltado para desenvolvedores e para o GitHub
> Copilot em repositórios que utilizam (ou pretendem utilizar) a gem `zyra`.
> Ele descreve como integrar e usar a gem sem precisar inspecionar o código-fonte
> do repositório original.

## O que é a gem `zyra`?

`zyra` é uma gem Ruby para **seeding idempotente** de banco de dados em projetos
Rails. Ela garante que determinadas entidades existam no banco sem duplicá-las a
cada execução de `rake db:seed`.

O fluxo básico é:

1. Você **registra** um modelo e define quais atributos servem de chave de busca.
2. Ao chamar `find_or_create`, a gem busca o registro pelas chaves fornecidas.
3. Se o registro **não existir**, ele é criado com todos os atributos fornecidos.
4. Se o registro **já existir**, ele é simplesmente retornado (sem duplicação).
5. Hooks opcionais permitem executar lógica extra em cada etapa do processo.

---

## Instalação

### Via `Gemfile` (recomendado para aplicações Rails)

Adicione ao `Gemfile`:

```ruby
gem 'zyra'
```

Em seguida, instale as dependências:

```bash
bundle install
```

### Via `gemspec` (para gems que dependem de `zyra`)

```ruby
spec.add_dependency 'zyra', '>= 1.2.0'
```

### Instalação direta

```bash
gem install zyra
```

---

## Requisitos

| Requisito     | Versão mínima |
|---------------|---------------|
| Ruby          | 2.7.0         |
| ActiveSupport | 7.0.4         |
| jace          | 0.1.1         |

`zyra` é compatível com qualquer framework ORM que use a interface do
`ActiveRecord` (ex.: Rails com ActiveRecord).

---

## Configuração inicial

A gem não requer arquivos de configuração, variáveis de ambiente nem
inicializadores separados. Basta incluir no código de seeding:

```ruby
require 'zyra'
```

Em projetos Rails a gem já é carregada automaticamente via Bundler.

---

## Uso em aplicações Rails

O local recomendado para usar `zyra` é o arquivo `db/seeds.rb`.

### Passo 1 — Registrar o modelo

Chame `Zyra.register` passando a classe do modelo e o atributo (ou lista de
atributos) que serve de chave de busca:

```ruby
# db/seeds.rb

Zyra.register(User, find_by: :email)
```

Múltiplas chaves:

```ruby
Zyra.register(Product, find_by: %i[sku store_id])
```

Registrar com uma chave simbólica personalizada (útil quando o mesmo modelo
precisa de mais de um registro):

```ruby
Zyra.register(User, :admin_user, find_by: :email)
```

> Quando a chave não é fornecida, ela é derivada automaticamente do nome da
> classe (ex.: `User` → `:user`, `Admin::User` → `:admin_user`).

### Passo 2 — Criar ou buscar o registro

```ruby
# db/seeds.rb

user = Zyra.find_or_create(
  :user,
  email: 'admin@example.com',
  name:  'Administrador',
  role:  'admin'
)
# => instância de User persistida no banco
```

Na **primeira execução** o usuário é criado com todos os atributos.
Nas **execuções seguintes** o usuário existente é encontrado pelo `email` e
retornado sem alterações (a menos que hooks sejam configurados).

### Passo 3 — Usar o bloco para atualizar sempre

O bloco passado a `find_or_create` é executado tanto na criação quanto no
retorno do registro encontrado, sendo útil para garantir que determinados campos
estejam sempre atualizados:

```ruby
attributes = {
  email:    'admin@example.com',
  name:     'Administrador',
  password: 'senha_segura'
}

Zyra.find_or_create(:user, attributes) do |user|
  user.update(attributes)
end
```

---

## Hooks disponíveis

Hooks são registrados com `Zyra.on(chave, evento)` (ou encadeados no retorno de
`register`). Os quatro eventos possíveis são:

| Evento    | Quando é disparado                                      |
|-----------|---------------------------------------------------------|
| `:build`  | Após o objeto ser instanciado (antes de salvar)         |
| `:create` | Após o objeto ser salvo pela primeira vez               |
| `:found`  | Quando o objeto é encontrado no banco                   |
| `:return` | Sempre, após `:build`/`:create`/`:found` (pós-retorno) |

### Exemplo: gerar token apenas na criação

```ruby
Zyra.register(User, find_by: :email)
    .on(:build) do |user|
      user.api_token = SecureRandom.hex(16)
    end

Zyra.find_or_create(:user, email: 'usr@srv.com', name: 'Fulano')
# O api_token é gerado somente na primeira vez
```

### Exemplo: forçar atualização a cada execução

```ruby
Zyra.register(User, find_by: :email)

Zyra.on(:user, :return) do |user|
  user.update(last_seeded_at: Time.current)
end

Zyra.find_or_create(:user, email: 'usr@srv.com')
# last_seeded_at é atualizado em toda execução do seed
```

### Exemplo: criar registros associados somente na criação

```ruby
Zyra.register(User, find_by: :email)
    .on(:build) do |user|
      user.posts.build(title: 'Bem-vindo', body: 'Primeiro post')
    end

Zyra.find_or_create(:user, email: 'usr@srv.com', name: 'Fulano').reload
# O post é criado somente quando o usuário é criado pela primeira vez
```

---

## Exemplo completo em `db/seeds.rb`

```ruby
# db/seeds.rb

# 1. Registrar modelos
Zyra.register(Role, find_by: :name)
Zyra.register(User, find_by: :email)
    .on(:build) { |u| u.api_token = SecureRandom.hex(16) }

# 2. Criar papéis
admin_role = Zyra.find_or_create(:role, name: 'admin')
user_role  = Zyra.find_or_create(:role, name: 'user')

# 3. Criar usuário administrador e sempre atualizar o nome
Zyra.find_or_create(
  :user,
  email: 'admin@example.com',
  name:  'Admin',
  role:  admin_role
) do |user|
  user.update(name: 'Admin')
end
```

Execute com:

```bash
rails db:seed
# ou, para recriar do zero:
rails db:reset
```

---

## Boas práticas e convenções

1. **Registre modelos antes de usá-los** — idealmente no topo de `db/seeds.rb`
   ou em um arquivo separado (`db/seeds/registrations.rb`) carregado no início.

2. **Use `find_by` com atributos únicos e estáveis** — emails, slugs, códigos
   internos. Evite atributos que mudam com frequência.

3. **Prefira o bloco para atualizações opcionais** — coloque no bloco apenas o
   que deve ser sempre atualizado; os atributos fora do bloco são usados somente
   na criação.

4. **Use hooks `:build` para dados que devem ser gerados somente uma vez** —
   tokens, referências únicas, etc.

5. **Use hooks `:return` para dados que devem ser sempre atualizados** —
   timestamps de auditoria, contadores, etc.

6. **Um `Zyra.register` por modelo por chave** — se precisar buscar o mesmo
   modelo por atributos diferentes, forneça uma chave simbólica distinta:

   ```ruby
   Zyra.register(User, :user_by_email, find_by: :email)
   Zyra.register(User, :user_by_name,  find_by: :name)
   ```

7. **Evite `Zyra.reset`** no código de produção — esse método existe para
   facilitar testes e limpa todos os registros configurados.

---

## Rake tasks relevantes

| Comando           | Descrição                                                    |
|-------------------|--------------------------------------------------------------|
| `rails db:seed`   | Executa `db/seeds.rb` (use `zyra` aqui)                      |
| `rails db:reset`  | Recria o banco e executa as seeds                            |
| `rails db:setup`  | Cria o banco, roda as migrations e executa as seeds          |

---

## Referências internas do repositório `darthjee/zyra`

| Arquivo                         | Responsabilidade                                         |
|---------------------------------|----------------------------------------------------------|
| `lib/zyra.rb`                   | Módulo principal; expõe `register`, `on`, `find_or_create` |
| `lib/zyra/registry.rb`          | Mantém o mapa de modelos registrados                     |
| `lib/zyra/finder_creator.rb`    | Orquestra a busca e a criação de um registro             |
| `lib/zyra/finder.rb`            | Realiza a busca no banco pelos atributos-chave           |
| `lib/zyra/creator.rb`           | Instancia e persiste um novo registro                    |
| `lib/zyra/exceptions.rb`        | Exceções da gem (`NotRegistered`, etc.)                  |
| `lib/zyra/version.rb`           | Constante de versão (`Zyra::VERSION`)                    |

Documentação YARD completa: <https://www.rubydoc.info/gems/zyra>
(substitua pela versão instalada no projeto, ex.: `/gems/zyra/1.2.0`)

Repositório: <https://github.com/darthjee/zyra>
