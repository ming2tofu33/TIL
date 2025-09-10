import os
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


class State(MessagesState):
    question: str   # User question
    sql: str        # Generated SQL
    result: str     # Database result
    answer: str     # Final answer


class SQLAgent:
    def __init__(self):
        # Load environment variables
        load_dotenv()
        
        # Initialize LLM
        self.llm = ChatOpenAI(model='gpt-4.1-nano', temperature=0)
        
        # Initialize database connection
        self.db = self._setup_database()
        
        # Setup prompt template
        self.query_prompt_template = self._setup_prompt_template()
        
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
    
    def _setup_prompt_template(self):
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

        To start you should ALWAYS look at the tables in the database to see what you
        can query. Do NOT skip this step.

        Then you should query the schema of the most relevant tables.
        """.format(dialect="postgresql", top_k=5)

        user_prompt = "Question: {input}"

        return ChatPromptTemplate([
            ('system', system_message),
            ('user', user_prompt)
        ])
    
    def write_sql(self, state: State):
        """Generate SQL query to fetch info"""
        prompt = self.query_prompt_template.invoke({
            "dialect": self.db.dialect,
            "top_k": 10,
            "table_info": self.db.get_table_info(),
            "input": state["question"],
        })
        
        structured_llm = self.llm.with_structured_output(QueryOutput)
        result = structured_llm.invoke(prompt)
        return {'sql': result["query"]}
    
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
    
    def _build_graph(self):
        """Build the LangGraph workflow"""
        builder = StateGraph(State).add_sequence([
            self.write_sql, 
            self.execute_sql, 
            self.generate_answer
        ])
        
        builder.add_edge(START, 'write_sql')
        
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
        
        # Run until SQL execution (where it will pause)
        for step in self.graph.stream(
            {'question': question},
            config,
            stream_mode='updates'
        ):
            if '__interrupt__' in step:
                print("Paused before SQL execution...")
                break
            else:
                print("SQL Generated:")
                if 'write_sql' in step:
                    print(f"  {step['write_sql']['sql']}")
        
        # Ask for user approval
        print("\n" + "=" * 50)
        user_approval = input('Continue with SQL execution? (y/n): ')
        print("=" * 50)
        
        if user_approval.lower() == 'y':
            # Continue from where it left off
            for step in self.graph.stream(None, config, stream_mode='updates'):
                if 'execute_sql' in step:
                    print("SQL Result:")
                    print(f"  {step['execute_sql']['result']}")
                elif 'generate_answer' in step:
                    print("\nFinal Answer:")
                    print(f"  {step['generate_answer']['answer']}")
            
            return self.get_final_state(config)
        else:
            print('Operation cancelled.')
            return None
    
    def run_automated(self, question: str, thread_id: str = "1"):
        """Run the agent without human intervention"""
        # Create a version without interrupts for automated execution
        builder = StateGraph(State).add_sequence([
            self.write_sql, 
            self.execute_sql, 
            self.generate_answer
        ])
        builder.add_edge(START, 'write_sql')
        auto_graph = builder.compile()
        
        config = {'configurable': {'thread_id': thread_id}}
        
        result = auto_graph.invoke({'question': question}, config)
        return result
    
    def get_final_state(self, config):
        """Get the final state of the conversation"""
        return self.graph.get_state(config)


def main():
    """Main function to run the SQL agent"""
    try:
        # Initialize the agent
        agent = SQLAgent()
        
        print("SQL Agent initialized successfully!")
        print("Database connection established.")
        
        # Interactive mode
        while True:
            question = input("\nAsk a question about the database (or 'quit' to exit): ")
            
            if question.lower() in ['quit', 'exit', 'q']:
                print("Goodbye!")
                break
            
            if not question.strip():
                print("Please enter a valid question.")
                continue
            
            try:
                result = agent.run_interactive(question)
                if result:
                    print(f"\nConversation completed. Thread ID: {result.config['configurable']['thread_id']}")
            except Exception as e:
                print(f"Error processing question: {str(e)}")
    
    except Exception as e:
        print(f"Failed to initialize SQL Agent: {str(e)}")
        print("Please check your environment variables and database connection.")


if __name__ == "__main__":
    main()
