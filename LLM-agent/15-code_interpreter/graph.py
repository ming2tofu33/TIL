from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import InMemorySaver
from nodes import generate_code, execute_code, generate_answer
from state import State


builder = StateGraph(State)
builder.add_sequence([generate_code, execute_code, generate_answer])

builder.add_edge(START, 'generate_code')
builder.add_edge('generate_answer', END)

memory = InMemorySaver()
graph = builder.compile(checkpointer=memory)