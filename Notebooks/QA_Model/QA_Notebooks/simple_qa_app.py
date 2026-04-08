import streamlit as st
import pdfplumber
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import nltk
nltk.download('punkt')  # for tokenization

from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
import string
from sklearn.metrics.pairwise import linear_kernel

nltk.download('wordnet')
nltk.download('stopwords')

lemmatizer = WordNetLemmatizer()
custom_stopwords = set(stopwords.words('english'))  # Add custom stopwords if needed

def extract_text_from_pdf(pdf_path):
    text = ''
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text += page.extract_text() + ' '  # add space between pages
    return text

def preprocess_text(text):
    # Remove punctuation
    text = text.translate(str.maketrans('', '', string.punctuation))
    # Tokenization and lemmatization
    return ' '.join([lemmatizer.lemmatize(word) for word in text.split() if word not in custom_stopwords])

def process_text(text):
    sentences = nltk.sent_tokenize(text)  # Split text into sentences
    processed_sentences = [preprocess_text(sentence) for sentence in sentences]
    vectorizer = TfidfVectorizer(stop_words='english', ngram_range=(1,2))
    vectors = vectorizer.fit_transform(processed_sentences)
    return sentences, vectors, vectorizer

def find_relevant_passage(question, sentences, vectors, vectorizer):
    question_vector = vectorizer.transform([preprocess_text(question)])
    similarities = linear_kernel(question_vector, vectors).flatten()
    top_indices = similarities.argsort()[-3:][::-1]  # Get indices of top 3 similarities
    # Optionally use additional scoring functions here
    return [sentences[index] for index in top_indices]


st.title('Simple PDF-based Question Answering System')
uploaded_file = st.file_uploader("Choose a PDF file", type="pdf")
user_question = st.text_input("Enter your question:")


if uploaded_file is not None and user_question:
    text_from_pdf = extract_text_from_pdf(uploaded_file)
    sentences, vectors, vectorizer = process_text(text_from_pdf)
    answer = find_relevant_passage(user_question, sentences, vectors, vectorizer)
    st.write('Relevant Information:', answer)
