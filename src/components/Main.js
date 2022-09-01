import React, { useState, useEffect } from "react";
import {
  MDBContainer,
  MDBNavbar,
  MDBNavbarBrand,
  MDBNavbarToggler,
  MDBIcon,
  MDBNavbarNav,
  MDBNavbarItem,
  MDBNavbarLink,
  MDBBtn,
  MDBDropdown,
  MDBDropdownToggle,
  MDBDropdownMenu,
  MDBDropdownItem,
  MDBDropdownLink,
  MDBCollapse,
  MDBInputGroup,
  MDBTable,
  MDBTableHead,
  MDBTableBody,
  MDBCard,
  MDBCardBody,
  MDBCardTitle,
  MDBBadge,
} from "mdb-react-ui-kit";
import { Container } from "@mui/system";
import { getBlocks } from "./Blockchain/Web3-api";
import { Grid } from "@mui/material";

export default function Main() {
  const [docBlock, setDocBlock] = useState();

  useEffect(() => {
    const init = async () => {
      const data = await getBlocks();
      setDocBlock(data);
    };
    init();
  }, []);

  const [showBasic, setShowBasic] = useState(false);

  const slicingHash = (str) => {
    const first = str.slice(0, 10);
    const second = str.slice(56);
    return first + "..." + second;
  };

  return (
    // NAVBAR
    <>
      <MDBNavbar expand="lg" light bgColor="light">
        <MDBContainer fluid>
          <MDBNavbarBrand href="#">Brand</MDBNavbarBrand>

          <MDBNavbarToggler
            aria-controls="navbarSupportedContent"
            aria-expanded="false"
            aria-label="Toggle navigation"
            onClick={() => setShowBasic(!showBasic)}
          >
            <MDBIcon icon="bars" fas />
          </MDBNavbarToggler>

          <MDBCollapse navbar show={showBasic}>
            <MDBNavbarNav className="mr-auto mb-2 mb-lg-0">
              <MDBNavbarItem>
                <MDBNavbarLink active aria-current="page" href="#">
                  Home
                </MDBNavbarLink>
              </MDBNavbarItem>
              <MDBNavbarItem>
                <MDBNavbarLink href="#">Link</MDBNavbarLink>
              </MDBNavbarItem>

              <MDBNavbarItem>
                <MDBDropdown>
                  <MDBDropdownToggle tag="a" className="nav-link">
                    Dropdown
                  </MDBDropdownToggle>
                  <MDBDropdownMenu>
                    <MDBDropdownItem>
                      <MDBDropdownLink>Action</MDBDropdownLink>
                    </MDBDropdownItem>
                    <MDBDropdownItem>
                      <MDBDropdownLink>Another action</MDBDropdownLink>
                    </MDBDropdownItem>
                    <MDBDropdownItem>
                      <MDBDropdownLink>Something else here</MDBDropdownLink>
                    </MDBDropdownItem>
                  </MDBDropdownMenu>
                </MDBDropdown>
              </MDBNavbarItem>

              <MDBNavbarItem>
                <MDBNavbarLink
                  disabled
                  href="#"
                  tabIndex={-1}
                  aria-disabled="true"
                >
                  Disabled
                </MDBNavbarLink>
              </MDBNavbarItem>
            </MDBNavbarNav>

            <MDBInputGroup
              tag="form"
              className="d-flex w-auto align-items-center"
            >
              <input
                className="form-control"
                placeholder="Type query"
                aria-label="Search"
                type="Search"
              />
              <MDBBtn outline className="mx-2">
                Search
              </MDBBtn>
            </MDBInputGroup>
          </MDBCollapse>
        </MDBContainer>
      </MDBNavbar>

      {/* CARDS */}
      <Container maxWidth="xl">
        <Grid
          container
          spacing={2}
          sx={{ marginTop: "20px", padding: "10px 20px" }}
        >
          <Grid item xs={12} sm={12} md={6} lg={3} xl={3}>
            <MDBCard className="mx-5">
              <MDBCardBody>
                <MDBCardTitle>GCS Market Cap</MDBCardTitle>
                <h4
                  style={{
                    fontWeight: " 500",
                    color: "#000000",
                    fontSize: "20px",
                  }}
                >
                  hello
                  <MDBBadge color="success" className="mx-2">
                    {/* <MDBIcon fas icon="chart-line" /> 70.32% */}
                  </MDBBadge>
                </h4>
              </MDBCardBody>
            </MDBCard>
          </Grid>
          <Grid item xs={12} sm={12} md={6} lg={3} xl={3}>
            <MDBCard className="mx-5">
              <MDBCardBody>
                <MDBCardTitle>GCS Market Cap</MDBCardTitle>
                <h4
                  style={{
                    fontWeight: " 500",
                    color: "#000000",
                    fontSize: "20px",
                  }}
                >
                  hello
                  <MDBBadge color="success" className="mx-2">
                    {/* <MDBIcon fas icon="chart-line" /> 70.32% */}
                  </MDBBadge>
                </h4>
              </MDBCardBody>
            </MDBCard>
          </Grid>
          <Grid item xs={12} sm={12} md={6} lg={3} xl={3}>
            <MDBCard className="mx-5">
              <MDBCardBody>
                <MDBCardTitle>GCS Market Cap</MDBCardTitle>
                <h4
                  style={{
                    fontWeight: " 500",
                    color: "#000000",
                    fontSize: "20px",
                  }}
                >
                  hello
                  <MDBBadge color="success" className="mx-2">
                    {/* <MDBIcon fas icon="chart-line" /> 70.32% */}
                  </MDBBadge>
                </h4>
              </MDBCardBody>
            </MDBCard>
          </Grid>{" "}
          <Grid item xs={12} sm={12} md={6} lg={3} xl={3}>
            <MDBCard className="mx-5">
              <MDBCardBody>
                <MDBCardTitle>GCS Market Cap</MDBCardTitle>
                <h4
                  style={{
                    fontWeight: " 500",
                    color: "#000000",
                    fontSize: "20px",
                  }}
                >
                  hello
                  <MDBBadge color="success" className="mx-2">
                    {/* <MDBIcon fas icon="chart-line" /> 70.32% */}
                  </MDBBadge>
                </h4>
              </MDBCardBody>
            </MDBCard>
          </Grid>
        </Grid>
      </Container>

      {/* TABLE */}
      <Container maxWidth="xl">
        <Grid container spacing={2}>
          <Grid item xs={12} sm={12} md={12} xl={6}>
            <MDBTable style={{ marginTop: "50px", border: "1px solid" }}>
              <MDBTableHead>
                <tr>
                  <th scope="col">Block Number</th>
                  <th scope="col">Txn</th>
                  <th scope="col">Gas Limit</th>
                  <th scope="col">Time</th>
                  <th scope="col">Hash</th>
                </tr>
              </MDBTableHead>
              <MDBTableBody>
                {docBlock &&
                  docBlock.map((item) => {
                    return (
                      <tr>
                        <th scope="row">{item.number}</th>
                        <td>{item.txn}</td>
                        <td>{item.gasLimit}</td>
                        <td>{item.timestamp}</td>
                        <td>{slicingHash(item.hash)}</td>
                      </tr>
                    );
                  })}
              </MDBTableBody>
            </MDBTable>
          </Grid>
          <Grid item xs={12} sm={12} md={12} xl={6}>
            <MDBTable style={{ marginTop: "50px", border: "1px solid" }}>
              <MDBTableHead>
                <tr>
                  <th scope="col">Block Number</th>
                  <th scope="col">Txn</th>
                  <th scope="col">Gas Limit</th>
                  <th scope="col">Time</th>
                  <th scope="col">Hash</th>
                </tr>
              </MDBTableHead>
              <MDBTableBody>
                {docBlock &&
                  docBlock.map((item) => {
                    return (
                      <tr>
                        <th scope="row">{item.number}</th>
                        <td>{item.txn}</td>
                        <td>{item.gasLimit}</td>
                        <td>{item.timestamp}</td>
                        <td>{slicingHash(item.hash)}</td>
                      </tr>
                    );
                  })}
              </MDBTableBody>
            </MDBTable>
          </Grid>
        </Grid>
      </Container>
    </>
  );
}
