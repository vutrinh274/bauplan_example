import bauplan
import streamlit as st
from streamlit_ace import st_ace
import os  



class BauplanClient:
    _instance = None  # Class-level variable

    @staticmethod
    def get():
        if BauplanClient._instance is None:
            BauplanClient._instance = bauplan.Client()
        return BauplanClient._instance

@st.cache_data
def run_query(sql_query, full_branch, namespace):
    client = BauplanClient.get()
    try:
        df = client.query(sql_query, ref=full_branch, namespace=namespace).to_pandas()
        st.write(df)
    except Exception as e:
        st.error(f"Error fetching data: {e}")


def main():
    # Initialize Bauplan client for data access
    st.title(":blue[Snowflake]'s SQL editor can't compare to this :sunglasses:")
    with st.expander("Show me the map"):
        st.image(os.getcwd() + "/streamlit/map.png", caption="Image created by the author.")
    client = BauplanClient.get()

    # Get all branches from Bauplan
    branches = [branch.name for branch in client.get_branches()]
    # Get unique users from branch names (assuming format: username.branchname)
    users = sorted(set(branch.split(".")[0] for branch in branches if "." in branch))
    # Create user dropdown in sidebar
    selected_user = st.sidebar.selectbox("Select bauplan user", ["None"] + users)
    # Only proceed if a user is selected
    sql_query = st_ace(placeholder="Input some SQL here", language="sql")
    if selected_user != "None":
        # Filter branches for selected user
        user_branches = [
            branch.split(".")[1]
            for branch in branches
            if branch.startswith(f"{selected_user}.")
        ]
        # Create branch dropdown
        selected_branch_name = st.sidebar.selectbox("Select Branch", ["None"]+ user_branches)
        # Construct full branch name
        if selected_branch_name == "None":
            st.error('Please choose a valid branch', icon="🚨")
        else:
            full_branch = f"{selected_user}.{selected_branch_name}"
            namespaces = [
                namespace.name for namespace in client.get_namespaces(ref=full_branch)
            ]
            selected_namespace = st.sidebar.selectbox("Select Namespace", ["None"]+ namespaces)
            if selected_namespace != "None":
                if sql_query != "":
                    run_query(
                        sql_query=sql_query,
                        full_branch=full_branch,
                        namespace=selected_namespace,
                    )
            else:
                st.error('Please select a namespace', icon="🚨")
    else:
        st.error('Please choose the valid user', icon="🚨")

if __name__ == "__main__":
    main()
