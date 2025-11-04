# APS Modelagem Preditiva

Projeto analítico que aplica técnicas de modelagem preditiva para compreender padrões e antecipar comportamentos a partir de dados reais.  
O estudo envolve a construção, comparação e interpretação de diferentes modelos de **classificação** e **regressão**, buscando transformar dados em decisões com base estatística.

---

## Estrutura do Projeto

```
modelagem_preditiva/
│
├── code/                           # scripts de análise e modelagem
├── data/                           # conjuntos de dados brutos e processados (⚠️ ignorados pelo Git)
├── docs/                           # enunciado da APS e relatório final
├── images/                         # gráficos, curvas ROC e outras visualizações
├── results/                        # arquivos csv's com os resultados da A1 e A2
├── .gitignore                      # arquivos e pastas ignorados no versionamento
├── main.R                          # arquivo pai, que gere os exercícios contidos na pasta code
├── modelagem_preditiva.Rproj       # arquivo RStudio do projeto 
└── README.md                       # visão geral do projeto

```

---

## Objetivos

- Desenvolver modelos preditivos aplicados a **cenários reais** (clientes e mercado automotivo);  
- Comparar o desempenho de algoritmos em termos de **acurácia**, **AUC** e **RMSE**;  
- Discutir a influência do **viés**, **variância** e **aleatorização** nos resultados;  
- Gerar **insights interpretáveis** para apoio à tomada de decisão.

---

### Pasta `data/`

A pasta `data/` contém todos os conjuntos de dados utilizados nas análises, divididos por aplicação e etapa.
Esses arquivos **não são versionados no GitHub** por questões de tamanho e privacidade, mas devem estar disponíveis localmente para a execução do projeto.

| Arquivo               | Descrição                                                                                             |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **`Q1_training.csv`** | Conjunto de **treinamento** utilizado para ajustar os modelos da Questão 1 (classificação binária).   |
| **`Q1_test.csv`**     | Conjunto de **teste** correspondente à Questão 1, usado para calcular a AUC e comparar modelos.       |
| **`churn.csv`**       | Base de dados de **clientes bancários**, utilizada na Aplicação 1 para prever o cancelamento (churn). |
| **`used_cars.csv`**   | Dados de **veículos Mercedes usados**, aplicados na regressão da Aplicação 2 para estimar preços.     |
| **`california.csv`**  | Base **California Housing**, usada nas Questões 2–4 para explorar bagging, random forests e erro OOB. |

> ⚠️ Caso os arquivos não estejam presentes, é necessário colocá-los manualmente na pasta `data/` antes de rodar os scripts.

---

## Execução do Projeto

O projeto pode ser executado no **VS Code** e **RStudio**.

### Passos iniciais

1. Clone este repositório:
```bash
   git clone https://github.com/gustavoribolla/modelagem_preditiva.git
   cd modelagem_preditiva
```

2. Abra no **VS Code** ou **RStudio**.

3. Instale as bibliotecas necessárias:

   ```r
   install.packages(c("tidyverse", "tree", "ranger", "pROC", "class", "catboost"))
   ```

4. Execute o script principal:

   ```r
   source("code/main.R")
   ```

5. As figuras geradas serão salvas automaticamente na pasta `images/` e os resultados das aplicações na pasta `results/`.

---

## Relatório

O relatório completo está disponível em:
📄 [Acesse aqui](https://alinsperedu-my.sharepoint.com/:w:/g/personal/gustavocr2_al_insper_edu_br/ES2YJpYvL7BOj9zKbNkkS_MBnUZtruXpNpnpJ3LVVA7_EA?e=1Rf1pi)

> O relatório apresenta a fundamentação teórica, resultados experimentais, discussões e conclusões do projeto.

---

## Modelos Utilizados

* Regressão Logística
* Árvores de Classificação e Regressão
* Bagging e Random Forests
* k-NN (k-Nearest Neighbors)
* CatBoost

---

## Aplicações

* **Problema de churn:** previsão de cancelamento de clientes em uma instituição bancária.
* **Preço de automóveis usados:** estimativa de valor de mercado com base em atributos de veículos Mercedes.

---

## Conceitos-Chave Abordados

* Relação entre **viés** e **variância**
* Uso de **bootstrap** no bagging
* Aleatorização de splits em **Random Forests**
* Estimativa de erro **Out-of-Bag (OOB)**
* Comparação de **curvas ROC** e **AUC**

---

## Autor

**Gustavo Colombi Ribolla**<br>
Estudante de Ciência da Computação - Insper<br>
📫 [linkedin.com/in/gustavoribolla](https://linkedin.com/in/gustavoribolla)
