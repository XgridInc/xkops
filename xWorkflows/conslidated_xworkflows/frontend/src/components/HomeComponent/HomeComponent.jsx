// import React from 'react';
// import { Link } from 'react-router-dom';
// import styled from 'styled-components';
// import Logo from '../../images/xkops_logo.png';
// import {Image } from "antd";
// import homeImg from '../../images/home-img.png'; 
// const HomeContainer= styled.div`
//     .flex-1{
//         display: flex;
//         justify-content: space-between;
//         // align-items: center;
//         // text-align: center;
//         //background-color: rgb(247, 247, 247);
//     }
//     .Head{
//         margin-top:4rem;
//     }
//     .Heading-1{
//         color:#538ACA;
//         font-size: 3rem;
//         font-weight: bold;
//         text-align: left;
//         margin-left:4rem;
//     }
//     .Details-1{
//         text-align: left;
//         color:#5E5858;
//         font-size: 1.2rem;
//         margin-left:4rem;
//     }
// `
// const HomeComponent = () => {
//   return (
//     <HomeContainer>
//         <div className='flex-1'>
//             <div className='Head'>
//                 <div className='Heading-1'>Simplify Kubernetes</div>
//                 <div className='Heading-1'>Management</div>
//                 <div className='Details-1'>XkOps empowers you to optimize resource utilization,</div>
//                 <div className='Details-1'>identify cost-saving opportunities, and maintain peak</div>
//                 <div className='Details-1'> performance with intelligent cost management.</div>
//             </div>
//             <div className='image'>
//                 <Image isPreviewVisible="false"
//                     src={homeImg}  
//                     alt="Home"
//                     preview={false}/>
//             </div>
//         </div>
//     </HomeContainer>
//   );
// };

// export default HomeComponent;
import React from 'react';
import { Image } from 'antd';
import homeImg from '../../images/home-img.png';
import styled from 'styled-components';

const GridContainer = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 16px; 
  //background-color: red;
`;

const Head = styled.div`
  //background-color: #f0f2f5; 
  margin-top: 4rem;
  padding: 4px;
      .Head{
        margin-top:4rem;
    }
    .Heading-1{
        color:#538ACA;
        font-size: 3rem;
        font-weight: bold;
        text-align: left;
        margin-left:4rem;
    }
    .Details{
        margin-top: 1.2rem;
        }
    .Details-1{
        text-align: left;
        color:#5E5858;
        font-size: 1.2rem;
        margin-left:4rem;
        margin-bottom: 0.6rem;
    }
`;

const MyImage = styled(Image)`
  width: 100%;
`;

const MyComponent = () => {
  return (
    <GridContainer>
      <Head className="Head">
                 <div className='Heading-1'>Simplify Kubernetes</div>
                 <div className='Heading-1'>Management</div>
                 <div className='Details'>
                    <div className='Details-1'>XkOps empowers you to optimize resource utilization,</div>
                    <div className='Details-1'>identify cost-saving opportunities, and maintain peak</div>
                    <div className='Details-1'> performance with intelligent cost management.</div>
                 </div>
      </Head>
      <div className="image">
        <MyImage
          src={homeImg}
          alt="Home"
          preview={false} // Disable preview hover effect
        />
      </div>
    </GridContainer>
  );
};

export default MyComponent;

