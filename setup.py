import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="rm2p-gwitr",
    version="0.1.0",
    author="Wiktor Duniec",
    author_email="robowiko@gmail.com",
    description="Ruby marshal decoder",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Gwitr/rm2p",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)
