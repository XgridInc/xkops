import React, { useState } from 'react';
import { Modal, InputNumber, Button, Form } from 'antd';

const ReplicaResizeModal = ({ visible, onClose, onSubmit, record }) => {
  const [form] = Form.useForm();
  const [replicas, setReplicas] = useState(1);  // Default replicas value

  const handleOk = () => {
    form.validateFields().then((values) => {
      onSubmit(values.replicas);
      form.resetFields(); // Reset the form after submission
    });
  };

  return (
    <Modal
      title={`Resize Replicas for ${record.pod}`}
      visible={visible}
      onCancel={onClose}
      onOk={handleOk}
      okText="Submit"
      cancelText="Cancel"
    >
      <Form form={form} layout="vertical">
        <Form.Item
          label="Number of Replicas"
          name="replicas"
          rules={[{ required: true, message: 'Please input the number of replicas!' }]}
        >
          <InputNumber
            min={1}
            value={replicas}
            onChange={(value) => setReplicas(value)}
          />
        </Form.Item>
      </Form>
    </Modal>
  );
};

export default ReplicaResizeModal;
