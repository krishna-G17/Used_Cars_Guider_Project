

# Import necessary libraries
import streamlit as st
import pdfplumber
from transformers import pipeline

# Load the Hugging Face pipeline for question answering
@st.cache(allow_output_mutation=True)
def load_model():
    model = pipeline('question-answering', model="distilbert-base-cased-distilled-squad")
    return model

qa_pipeline = load_model()

# Function to extract text from PDF
def extract_text_from_pdf(pdf_file):
    text = ''
    with pdfplumber.open(pdf_file) as pdf:
        for page in pdf.pages:
            text += page.extract_text() + '\n'
    return text

# Streamlit user interface
def main():
    st.title('PDF Question Answering System')
    pdf_file = st.file_uploader("Upload a PDF file", type=['pdf'])
    question = st.text_input("Input your question here:")
    if st.button("Answer Question"):
        if pdf_file is not None and question:
            # Extract text and perform QA
            context = extract_text_from_pdf(pdf_file)
            answer = qa_pipeline(question=question, context=context)
            st.write('Answer:', answer['answer'])
        else:
            st.write("Please upload a PDF file and enter a question.")

if __name__ == "__main__":
    main()
