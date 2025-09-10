import os
import re
from dotenv import load_dotenv
from typing_extensions import Annotated, TypedDict

from langchain_openai import ChatOpenAI
from langchain_community.utilities import SQLDatabase
from langchain_community.tools.sql_database.tool import QuerySQLDataBaseTool
from langchain_core.prompts import ChatPromptTemplate
from langgraph.graph import MessagesState, START, StateGraph
from langgraph.checkpoint.memory import MemorySaver


class QueryOutput(TypedDict):
    """Generate SQL query"""
    query: Annotated[str, ..., 'Syntactically correct SQL query']


class ClassificationOutput(TypedDict):
    """Question classification result"""
    is_sql_related: Annotated[bool, ..., 'Whether the question requires database query']
    reasoning: Annotated[str, ..., 'Reasoning for the classification']


class State(MessagesState):
    question: str           # User question
    is_sql_related: bool   # Whether question needs SQL
    sql: str               # Generated SQL
    schema_valid: bool     # Whether SQL matches schema
    result: str            # Database result
    answer: str            # Final answer


class SQLAgent:
    def __init__(self):
        # Load environment variables
        load_dotenv()
        
        # Initialize LLM
        self.llm = ChatOpenAI(model='gpt-4.1-nano', temperature=0)
        
        # Initialize database connection
        self.db = self._setup_database()
        
        # Setup prompt templates
        self.classification_prompt = self._setup_classification_prompt()
        self.query_prompt_template = self._setup_query_prompt_template()
        self.direct_answer_prompt = self._setup_direct_answer_prompt()
        
        # Build graph
        self.graph = self._build_graph()
    
    def _setup_database(self):
        """Setup PostgreSQL database connection"""
        postgres_user = os.getenv('POSTGRES_USER')
        postgres_password = os.getenv('POSTGRES_PASSWORD')
        postgres_db = os.getenv('POSTGRES_DB')
        
        if not all([postgres_user, postgres_password, postgres_db]):
            raise ValueError("Missing required database environment variables")
        
        uri = f'postgresql://{postgres_user}:{postgres_password}@localhost:5432/{postgres_db}'
        return SQLDatabase.from_uri(uri)
    
    def _setup_classification_prompt(self):
        """Setup prompt for classifying if question needs SQL"""
        system_message = """
        You are a question classifier. Determine if a user's question requires querying a database or can be answered directly.

        Questions that REQUIRE database query (is_sql_related = true):
        - Questions about specific data, counts, statistics from database
        - Questions asking for records, lists, or filtering data
        - Questions about relationships between data entities
        - Examples: "How many employees?", "Show me all products", "What's the average salary?"

        Questions that DON'T require database query (is_sql_related = false):
        - General knowledge questions
        - Questions about concepts, definitions, explanations
        - Greetings, casual conversation
        - Questions about how to do something (not asking for actual data)
        - Examples: "Hello", "What is SQL?", "How do I write a query?", "What's the weather?"

        Return your classification with clear reasoning.
        """
        
        user_prompt = "Question: {question}"
        
        return ChatPromptTemplate([
            ('system', system_message),
            ('user', user_prompt)
        ])
    
    def _setup_query_prompt_template(self):
        """Setup the prompt template for SQL generation"""
        system_message = """
        You are an agent designed to interact with a SQL database.
        Given an input question, create a syntactically correct {dialect} query to run,
        then look at the results of the query and return the answer. Unless the user
        specifies a specific number of examples they wish to obtain, always limit your
        query to at most {top_k} results.

        You can order the results by a relevant column to return the most interesting
        examples in the database. Never query for all the columns from a specific table,
        only ask for the relevant columns given the question.

        You MUST double check your query before executing it. If you get an error while
        executing a query, rewrite the query and try again.

        DO NOT make any DML statements (INSERT, UPDATE, DELETE, DROP etc.) to the
        database.

        Available tables and schema:
        {table_info}
        """.format(dialect="postgresql", top_k=5, table_info="{table_info}")

        user_prompt = "Question: {input}"

        return ChatPromptTemplate([
            ('system', system_message),
            ('user', user_prompt)
        ])
    
    def _setup_direct_answer_prompt(self):
        """Setup prompt for direct answers without SQL"""
        system_message = """
        You are a helpful assistant. Answer the user's question directly based on your general knowledge.
        The user's question does not require database access.
        """
        
        user_prompt = "Question: {question}"
        
        return ChatPromptTemplate([
            ('system', system_message),
            ('user', user_prompt)
        ])
    
    def classify_question(self, state: State):
        """Classify if question requires SQL query"""
        prompt = self.classification_prompt.invoke({
            "question": state["question"]
        })
        
        structured_llm = self.llm.with_structured_output(ClassificationOutput)
        result = structured_llm.invoke(prompt)
        
        return {
            'is_sql_related': result["is_sql_related"]
        }
    
    def generate_direct_answer(self, state: State):
        """Generate direct answer for non-SQL questions"""
        prompt = self.direct_answer_prompt.invoke({
            "question": state["question"]
        })
        
        response = self.llm.invoke(prompt)
        return {'answer': response.content}
    
    def write_sql(self, state: State):
        """Generate SQL query to fetch info"""
        prompt = self.query_prompt_template.invoke({
            "table_info": self.db.get_table_info(),
            "input": state["question"],
        })
        
        structured_llm = self.llm.with_structured_output(QueryOutput)
        result = structured_llm.invoke(prompt)
        return {'sql': result["query"]}
    
    def validate_schema(self, state: State):
        """Validate if generated SQL matches available schema"""
        try:
            # Get available tables
            available_tables = self.db.get_usable_table_names()
            
            # Extract table names from SQL query
            sql_query = state['sql'].lower()
            
            # Simple regex to find table names after FROM and JOIN
            table_pattern = r'\b(?:from|join)\s+([a-zA-Z_][a-zA-Z0-9_]*)'
            mentioned_tables = re.findall(table_pattern, sql_query)
            
            # Check if all mentioned tables exist
            invalid_tables = [table for table in mentioned_tables if table not in [t.lower() for t in available_tables]]
            
            if invalid_tables:
                return {
                    'schema_valid': False,
                    'answer': f"죄송합니다. 현재 데이터베이스 스키마에서 다음 테이블을 찾을 수 없습니다: {', '.join(invalid_tables)}. 사용 가능한 테이블: {', '.join(available_tables)}"
                }
            else:
                return {'schema_valid': True}
                
        except Exception as e:
            return {
                'schema_valid': False,
                'answer': f"스키마 검증 중 오류가 발생했습니다: {str(e)}"
            }
    
    def execute_sql(self, state: State):
        """Execute SQL query"""
        try:
            execute_query_tool = QuerySQLDataBaseTool(db=self.db)
            result = execute_query_tool.invoke(state['sql'])
            return {'result': result}
        except Exception as e:
            return {'result': f"Error executing query: {str(e)}"}
    
    def generate_answer(self, state: State):
        """Generate final answer based on question and SQL results"""
        prompt = f""" 
        Based on the user question and the SQL query results from the database, provide a clear answer.
        
        Question: {state['question']}
        ---
        SQL Query: {state['sql']}
        SQL Result: {state['result']}
        """
        
        response = self.llm.invoke(prompt)
        return {'answer': response.content}
    
    def _route_after_classification(self, state: State):
        """Route based on question classification"""
        if state['is_sql_related']:
            return 'write_sql'
        else:
            return 'generate_direct_answer'
    
    def _route_after_schema_validation(self, state: State):
        """Route based on schema validation"""
        if state['schema_valid']:
            return 'execute_sql'
        else:
            return '__end__'  # End here, answer already set in validate_schema
    
    def _build_graph(self):
        """Build the LangGraph workflow with conditional routing"""
        builder = StateGraph(State)
        
        # Add nodes
        builder.add_node('classify_question', self.classify_question)
        builder.add_node('generate_direct_answer', self.generate_direct_answer)
        builder.add_node('write_sql', self.write_sql)
        builder.add_node('validate_schema', self.validate_schema)
        builder.add_node('execute_sql', self.execute_sql)
        builder.add_node('generate_answer', self.generate_answer)
        
        # Add edges
        builder.add_edge(START, 'classify_question')
        
        # Conditional routing after classification
        builder.add_conditional_edges(
            'classify_question',
            self._route_after_classification,
            {
                'write_sql': 'write_sql',
                'generate_direct_answer': 'generate_direct_answer'
            }
        )
        
        # Direct answer path ends here
        builder.add_edge('generate_direct_answer', '__end__')
        
        # SQL path continues
        builder.add_edge('write_sql', 'validate_schema')
        
        # Conditional routing after schema validation
        builder.add_conditional_edges(
            'validate_schema',
            self._route_after_schema_validation,
            {
                'execute_sql': 'execute_sql',
                '__end__': '__end__'
            }
        )
        
        # Continue SQL execution path
        builder.add_edge('execute_sql', 'generate_answer')
        builder.add_edge('generate_answer', '__end__')
        
        # Setup memory and interrupt before SQL execution for human approval
        memory = MemorySaver()
        return builder.compile(
            checkpointer=memory, 
            interrupt_before=['execute_sql']
        )
    
    def run_interactive(self, question: str, thread_id: str = "1"):
        """Run the agent with human-in-the-loop interaction"""
        config = {'configurable': {'thread_id': thread_id}}
        
        print(f"Processing question: {question}")
        print("=" * 50)
        
        # Run until interruption or completion
        final_result = None
        for step in self.graph.stream(
            {'question': question},
            config,
            stream_mode='updates'
        ):
            if '__interrupt__' in step:
                print("Paused before SQL execution...")
                break
            else:
                # Show progress
                for node_name, node_output in step.items():
                    if node_name == 'classify_question':
                        is_sql = node_output.get('is_sql_related', False)
                        print(f"Question Classification: {'SQL-related' if is_sql else 'Non-SQL'}")
                    elif node_name == 'write_sql':
                        print(f"Generated SQL: {node_output.get('sql', '')}")
                    elif node_name == 'validate_schema':
                        if not node_output.get('schema_valid', True):
                            print(f"Schema validation failed: {node_output.get('answer', '')}")
                            final_result = node_output.get('answer', '')
                    elif node_name == 'generate_direct_answer':
                        print(f"Direct Answer: {node_output.get('answer', '')}")
                        final_result = node_output.get('answer', '')
        
        # If we got a final result (non-SQL or schema error), return it
        if final_result:
            return final_result
        
        # Otherwise, continue with SQL execution approval
        print("\n" + "=" * 50)
        user_approval = input('Continue with SQL execution? (y/n): ')
        print("=" * 50)
        
        if user_approval.lower() == 'y':
            # Continue from where it left off
            for step in self.graph.stream(None, config, stream_mode='updates'):
                for node_name, node_output in step.items():
                    if node_name == 'execute_sql':
                        print(f"SQL Result: {node_output.get('result', '')}")
                    elif node_name == 'generate_answer':
                        answer = node_output.get('answer', '')
                        print(f"Final Answer: {answer}")
                        return answer
        else:
            print('Operation cancelled.')
            return None
    
    def run_automated(self, question: str, thread_id: str = "1"):
        """Run the agent without human intervention"""
        # Create a version without interrupts for automated execution
        builder = StateGraph(State)
        
        # Add nodes (same as interactive version)
        builder.add_node('classify_question', self.classify_question)
        builder.add_node('generate_direct_answer', self.generate_direct_answer)
        builder.add_node('write_sql', self.write_sql)
        builder.add_node('validate_schema', self.validate_schema)
        builder.add_node('execute_sql', self.execute_sql)
        builder.add_node('generate_answer', self.generate_answer)
        
        # Add edges (same routing logic but no interrupts)
        builder.add_edge(START, 'classify_question')
        builder.add_conditional_edges(
            'classify_question',
            self._route_after_classification,
            {
                'write_sql': 'write_sql',
                'generate_direct_answer': 'generate_direct_answer'
            }
        )
        builder.add_edge('generate_direct_answer', '__end__')
        builder.add_edge('write_sql', 'validate_schema')
        builder.add_conditional_edges(
            'validate_schema',
            self._route_after_schema_validation,
            {
                'execute_sql': 'execute_sql',
                '__end__': '__end__'
            }
        )
        builder.add_edge('execute_sql', 'generate_answer')
        builder.add_edge('generate_answer', '__end__')
        
        auto_graph = builder.compile()
        
        config = {'configurable': {'thread_id': thread_id}}
        result = auto_graph.invoke({'question': question}, config)
        return result.get('answer', 'No answer generated')


def main():
    """Main function to run the SQL agent"""
    try:
        # Initialize the agent
        agent = SQLAgent()
        
        print("SQL Agent initialized successfully!")
        print("Database connection established.")
        
        # Interactive mode
        while True:
            question = input("\nAsk a question (or 'quit' to exit): ")
            
            if question.lower() in ['quit', 'exit', 'q']:
                print("Goodbye!")
                break
            
            if not question.strip():
                print("Please enter a valid question.")
                continue
            
            try:
                result = agent.run_interactive(question)
                if result:
                    print(f"\nAnswer: {result}")
            except Exception as e:
                print(f"Error processing question: {str(e)}")
    
    except Exception as e:
        print(f"Failed to initialize SQL Agent: {str(e)}")
        print("Please check your environment variables and database connection.")


if __name__ == "__main__":
    main()
